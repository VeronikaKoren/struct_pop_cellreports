
% compute ccg noise
% within group (within plus and within minus neurons) and across groups of plus and minus
% cross-correlation function (ccg_raw - ccg_trial_invariant)
% 1 condition (concatenated trials from match and non-match)

close all
clear all
clc
format long

place=1;

saveres=0;                                                                          % save result?
showfig=1;

ba=2;
period=2; 
window=2;

nshuffle=2;                                                                   % number of trial permutations for computing the trial invariant ccg 
nperm=2;

start_vec=[500,500,750] - 300*(period==1);                                    % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};        

disp(['ccg info ',namea{ba},' ', namep{period},' ',namew{window}])

%% load data

addpath '/home/veronika/synced/struct_result/weights/weights_regular/';
addpath '/home/veronika/synced/struct_result/weights/tag/';
addpath '/home/veronika/synced/struct_result/input/';

if place==1
    addpath '/home/veronika/Dropbox/struct_pop/code/function/'
else
    addpath '/home/veronika/struct_pop/code/function/'
end

loadname=['tag_info_',namea{ba},namep{period}];
load(loadname);

loadname2=['spike_train_',namea{ba},'_',namep{period}];
load(loadname2);

strain=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);
    
%%                                                                          

nbses=size(tag_info,1);

infoc=cell(nbses,1);
notinfoc=cell(nbses,1);

p1=cell(nbses,1);
p2=cell(nbses,1);

tic
parfor sess = 1:nbses
    
    st=strain{sess};
    N=size(st,2);
    
    % info
    idx_i=find(tag_info{sess});
    n2=length(idx_i);
    spike_train=st(:,idx_i,:);
    infoc{sess} = ccg_fun(spike_train, nshuffle);
    
    % not info
    idx_noi=find(tag_info{sess}==0);
    n1=length(idx_noi);
    spike_train=st(:,idx_noi,:);
    notinfoc{sess} = ccg_fun(spike_train, nshuffle);
      
    %% permuted neural index
    n1p=(n1^2-n1)/2;
    n2p=(n2^2-n2)/2;
    rpn=zeros(n1p,nperm,2*K-1);
    rpi=zeros(n2p,nperm,2*K-1);
    
    for p=1:nperm
        
        permn=randperm(N);
        
        % group 1
        idx_p1=permn(1:n1);
        spike_train=st(:,idx_p1,:);
        rpn(:,p,:) = ccg_fun(spike_train, nshuffle);
        
        % group 2
        idx_p2=permn(n1+1:end);
        spike_train=st(:,idx_p2,:);
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

lags=-K+1:K-1;
%%

d=mean(info_fun(:,K))-mean(notinfo_fun(:,K));
d0=mean(nip(:,:,K))- mean(ip(:,:,K));

pval=sum(d<d0)/nperm;
display(pval,'p-value permutation test')
%%

if showfig==1
    
    figure()
    hold on
    ecdf(info_fun(:,K))
    ecdf(notinfo_fun(:,K))
 
end

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/pairwise/ccg/ccg_info/';
    filename=['ccg_info_',namea{ba},namep{period},namew{windows}];
    save([address, filename], 'info_fun','notinfo_fun','ip', 'nip','lags','pval')
    %clear all
end





