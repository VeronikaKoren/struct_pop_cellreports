
% compute ccg noise
% within group (within plus and within minus neurons) and across groups of plus and minus
% cross-correlation function (ccg_raw - ccg_trial_invariant)
% 1 condition (concatenated trials from match and non-match)

close all
clear all
clc
format long

place=1;

saveres=1;                                                                          % save result?
showfig=0;

ba=2;
period=2; 
cond=2;

nshuffle=10;                                                                   % number of trial permutations for computing the trial invariant ccg 
nperm=10;

start_vec=[200,500];                                                             % beginning of the time window for the target (200) and the test stimulus (500) 
start=start_vec(period);

K=500;
Nuse=4;

namea={'V1','V4'};
namep={'target','test'};
namec={'nm','m'};              

display(['ccg info ',namea{ba},' ', namep{period},' condition ', namec{cond}])

%% load data

addpath('/home/veronika/synced/struct_result/weights/weights_regular/');
addpath('/home/veronika/synced/struct_result/input/');

if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname=['svmw_',namea{ba},namep{period},'.mat'];                   
load(loadname)

loadname2=['spike_train_',namea{ba},'_',namep{period}];
load(loadname2);

strain=cellfun(@(x) single(x(:,:,start:start+K-1)),spiketrain(:,cond), 'UniformOutput', false);
    
%%                                                                          
np=(Nuse^2-Nuse)/2;
nbses=size(weight_all,1);

infoc=cell(nbses,1);
notinfoc=cell(nbses,1);

p1=cell(nbses,1);
p2=cell(nbses,1);

tic
parfor sess = 1:nbses
    
    display(sess,'session')
    
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

info=cell2mat(infoc);
notinfo=cell2mat(notinfoc);

nip=cell2mat(p1);
ip=cell2mat(p2);

%%

[h,p]=ttest2(info(:,K),notinfo(:,K),'tail','right');

d=mean(info(:,K)-notinfo(:,K));
d0=mean(nip(:,:,K)- ip(:,:,K));

pval=sum(d<d0)/nperm;
%%
lags=-K+1:K-1;

if showfig==1
    
    figure()
    subplot(2,2,1)
    plot(lags,mean(info))
    ylim([-0.01,0.06])
    xlim([-200,200])
    
    subplot(2,2,2)
    plot(lags,mean(notinfo))
    ylim([-0.01,0.06])
    
    
end

%% save results

if saveres==1
    address='/home/veronika/struct_pop/result/pairwise/ccg/ccg_info_conditions/';
    filename=['ccg_info_',namea{ba},'_',namep{period}, '_',namec{cond}];
    save([address, filename], 'info','notinfo','ip', 'nip','lags','pval')
    clear all
end




