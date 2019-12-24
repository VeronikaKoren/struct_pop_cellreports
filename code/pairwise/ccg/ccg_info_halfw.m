% compute ccg noise
% within group (within plus and within minus neurons) and across groups of plus and minus
% cross-correlation function (ccg_raw - ccg_trial_invariant)
% 1 condition (concatenated trials from match and non-match)
% first or second half or the trial

close all
clear all
clc
format long

place=1;

saveres=0;                                                                  % save result?
showfig=1;

period=2;
ba=2;
wind=1;

nshuffle=2;                                                                 % number of trial permutations for computing the trial invariant ccg 
nperm=2;

%%
start_vec=[200,200+250;500,500+250];                                        % beginning of the time window 
start=start_vec(period,window);
K=250;

Nuse=4;

namea={'V1','V4'};
namep={'target','test'};
namew={'first_half','second_half'};
   
disp(['ccg info ',namea{ba},' ', namep{period},' ',namew{wind}])

%% load spikes

addpath('/home/veronika/synced/struct_result/input/');

if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname=['spike_train_',namea{ba},'_',namep{period}];
load(loadname);
strain=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);
    
%% load weights

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
loadname=['svmw_',namew{wind},'_',namea{ba},namep{period},'.mat'];                   
load(loadname)

%%                                                                          
np=(Nuse^2-Nuse)/2;
nbses=size(weight_all,1);

infoc=cell(nbses,1);
notinfoc=cell(nbses,1);

p1=cell(nbses,1);
p2=cell(nbses,1);

tic
for sess = 1:nbses
    
   
    st=strain{sess};
    w=abs(weight_all{sess});
    [val,idx]=sort(w);
    N=length(w);
    
    % not info
    nidx=idx(1:Nuse);
    spike_train=st(:,nidx,:);
    notinfoc{sess} = ccg_fun(spike_train, nshuffle);
    
    
    % info
    iidx=idx(end-Nuse+1:end);
    spike_train=st(:,iidx,:);
    infoc{sess} = ccg_fun(spike_train, nshuffle);
    
    %% permuted
    rpn=zeros(np,nperm,2*K-1);
    rpi=zeros(np,nperm,2*K-1);
    
    for p=1:nperm
        
        permn=randperm(N);
        
        % group 1
        pidx=permn(1:Nuse);
        spike_train=st(:,pidx,:);
        rpn(:,p,:) = ccg_fun(spike_train, nshuffle);
        
        % group 2
        pidx=permn(end-Nuse+1:end);
        spike_train=st(:,pidx,:);
        rpi(:,p,:) = ccg_fun(spike_train, nshuffle);
    end
    
    p1{sess}=rpn;
    p2{sess}=rpi;
    
end
toc
%%

info_fun=cell2mat(infoc);
notinfo_fun=cell2mat(notinfoc);

nip=cell2mat(p1);
ip=cell2mat(p2);

%%

d=mean(info_fun(:,K)-notinfo_fun(:,K));
d0=mean(nip(:,:,K)- ip(:,:,K));

pval=sum(d<d0)/nperm;
%%
lags=-K+1:K-1;

if showfig==1
    
    figure()
    hold on
    plot(lags,mean(info_fun),'color',[1,0.3,0.05])
    plot(lags,mean(notinfo_fun),'color',[0.2,0.2,0.2])
    ylim([-0.01,0.08])
    xlim([-200,200])
    
    
end

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/pairwise/ccg/ccg_info/';
    filename=['ccg_info_',namew{wind},'_',namea{ba},'_',namep{period}];
    save([address, filename], 'info_fun','notinfo_fun','ip', 'nip','lags','pval')
    %clear all
end





