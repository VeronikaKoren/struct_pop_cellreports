
% compute ccg noise
% within group (within plus and within minus neurons) and across groups of plus and minus
% cross-correlation function (ccg_raw - ccg_trial_invariant)
% 1 condition (concatenated trials from match and non-match)
% uses weights from the first/second half of the trial

close all
clear all
clc 
format long

saveres=0;
showfig=1;

ba=2;
period=2;

window=1;                                                                       % 1 for the first half and 2 for the second    

nperm=1;                                                                       % permutation of sign
nshuffle=2;                                                                     % trial shuffle to subtract the signal correlation

%%

K=250;
start_vec=[200,200+250;500,500+250];                                    % beginning of the time window 
start=start_vec(period,window);

namea={'V1','V4'};
namep={'target', 'test'};
namew={'first_half','second_half'};

%% load spike counts                                                                         

addpath('/home/veronika/synced/struct_result/weights/weights_regular/');
addpath('/home/veronika/synced/struct_result/input/');
addpath('/home/veronika/Dropbox/struct_pop/code/function/')

loadname=['spike_train_',namea{ba},'_',namep{period}];
load(loadname);

strain=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);

%% load weights

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
loadname=['svmw_',namew{window},'_',namea{ba},namep{period},'.mat'];                   
load(loadname)
w_vec=cell2mat(cellfun(@(x) double(permute(x,[2,1])),weight_all,'UniformOutput', false));
w_abs=max(abs(w_vec));

nbses=size(weight_all,1);
%%                                                                          

display(['computing ccg within and across coding pools in ', namea{ba}, namew{window}])

cminus=cell(nbses,1);
cplus=cell(nbses,1);
cplusminus=cell(nbses,1);
pw=cell(nbses,nperm);
pa=cell(nbses,nperm);

tic
parfor sess = 1:nbses
    
    st=double(strain{sess});
    w=weight_all{sess};
    N=length(w);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% regular
    % (-/-)
    neg=find(w<0);
    if length(neg)>1
        spike_train=st(:,neg,:);
        cminus{sess} = ccg_fun(spike_train, nshuffle);
    end
    
    % (+/+)
    pos=find(w>0);
    if length(pos)>1
        spike_train=st(:,pos,:);
        cplus{sess} = ccg_fun(spike_train, nshuffle);
    end
    
    % (+/-)
    if abs(sum(sign(w)))<length(w)
        spike_train=st;
        cplusminus{sess} = ccg_pm_fun(spike_train,w,nshuffle);
    end
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% permuted
    %%
    
    
    w_nosign=w.*sign(w);                                                    % all positive
    
    for perm=1:nperm
        wrs=sign(- w_abs + (w_abs + w_abs).*rand(N,1)');                    % random sign
        w_perm=w_nosign.*wrs;                                                      % apply random sign
        
        % p1
        neg=find(w_perm<0);
        peak1=[];
        if length(neg)>1
            spike_train=st(:,neg,:);
            [ccg]=ccg_fun(spike_train, nshuffle);
            peak1=ccg(:,K)';
        end
        
        % p2
        pos=find(w_perm>0);
        peak2=[];
        if length(pos)>1
            spike_train=st(:,pos,:);
            [ccg]=ccg_fun(spike_train, nshuffle);
            peak2=ccg(:,K)';
        end
        pw{sess,perm}=cat(2,peak1,peak2)';
        
        % p12
        if min([length(pos),length(neg)])>1                                         % at least two neurons in each group
            spike_train=st;
            [ccg]=ccg_pm_fun(spike_train,wrs, nshuffle);
            
            pa{sess,perm}=ccg(:,K);
            
            
        end
    end
    %}
end
toc
%%

ccg_within=cell2mat(cellfun(@(x,y) cat(1,x,y),cplus,cminus,'UniformOutput', false));
ccg_across=cell2mat(cplusminus);

d=mean(ccg_within(:,K))-mean(ccg_across(:,K));

%%

pwp=zeros(nperm,1);
pap=zeros(nperm,1);
for perm=1:nperm
    pap(perm)=mean(cell2mat(pa(:,perm)));      % average across neurons
    pwp(perm)=mean(cell2mat(pw(:,perm)));
    
end

d0=pap-pwp;
pval=sum(d<d0)/nperm;
lags=-K+1:K-1;
display(pval)

%%

if showfig==1
   
    
    figure()
    subplot(1,2,1)
    hold on
    plot(lags,mean(ccg_within))
    plot(lags+10,mean(ccg_across))
    ylim([-0.01,0.06])
    xlim([-200,200])
    hold off
    ylim([-0.02,.07])
    legend('within pool','across pool')
    
    peak_within=ccg_within(:,K);
    peak_across=ccg_across(:,K);
    mpeak=[mean(peak_within),mean(peak_across)];
    
    subplot(1,2,2)
    hold on
    bar(1,mpeak(1),'b')
    bar(2,mpeak(2),'r')
    hold off
    ylim([-0.02,.07])
    
end

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/pairwise/ccg/ccg_sign/';
    filename=['ccg_sign_',namew{window},'_',namea{ba},'_',namep{period}];
    save([address, filename], 'ccg_within','ccg_across','pwp','pap','pval', 'lags')
    %clear all
end





