% noise correlations between informative and uninformative neurons
% permutation test with random neural index

close all
clear all
clc 
format long

saveres=0;
showfig=1;

ba=2;
period=2;

nperm=1000;

start_vec=[200,500];                                   % onset for the target (200) and the test stimulus (500) 
start=start_vec(period);
K=500;

display([start,start+K],'window')

%% load spike counts and tags

namea={'V1','V4'};
namep={'target', 'test'};
%condition={'nm','m'};


addpath('/home/veronika/Dropbox/struct_pop/code/function/')                    % load spike counts
addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/tag/')

loadname=['spike_train_',namea{ba},'_',namep{period}];
load(loadname);

loadname3=['tag_info_', namea{ba},namep{period}];         % load tag informative neurons in the right window
load(loadname3)

strain=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);
% if single condition:
%strain=cellfun(@(x) single(x(:,:,start:start+K-1)),spiketrain, 'UniformOutput', false);   % use the desired time window
sc_all=cellfun(@(x) squeeze(sum(x,3)) ,strain, 'UniformOutput',false);

nbses=size(sc_all,1);

%% compute rsc noise between pairs of informative/not informative neurons
tic

display(['computing rsc for informative and uninformative neurons in ', namea{ba}, ' during ', namep{period}])

infoc=cell(nbses,1);
notinfoc=cell(nbses,1);

p1=cell(nbses,1);
p2=cell(nbses,1);

parfor sess=1:nbses                                                                  % across recording sessions
    
    sc_sess=sc_all{sess};
    N=size(sc_sess,2);
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% regular
    
    % informative
    idx_i=find(tag_info{sess});
    n1=length(idx_i);
 
    if n1>1
        input=sc_sess(:,idx_i);
        [ r] = noise_correlation_sc_fun( input);
        infoc{sess}=r;
    end
    
    % not informative
    idx_noi=find(tag_info{sess}==0);
    n2=length(idx_noi);
    if n2>1
        input=sc_sess(:,idx_noi);
        notinfoc{sess} = noise_correlation_sc_fun( input);
    end
    
    %%%%%%%%%%%%%%%%%%%%%% permuted
    n1=round(N/2);        % balance number of neurons in a group for permutations
    n2=N-n1;
    np1=(n1^2-n1)/2;
    np2=(n2^2-n2)/2;
   
    rp1=zeros(np1,nperm);
    rp2=zeros(np2,nperm);
    
    for perm=1:nperm
        
        random_idx=randperm(N);
        input=sc_sess(:,random_idx(1:n1));
        [ r] = noise_correlation_sc_fun( input);
        rp1(:,perm)=r;
        
        input=sc_sess(:,random_idx(n1+1:end));
        [ r] = noise_correlation_sc_fun( input);
        rp2(:,perm)=r;
    end
    
    p1{sess}=rp1;
    p2{sess}=rp2;
    
    
end

toc

%%
imat=cell2mat(infoc);
nmat=cell2mat(notinfoc);

nip=cell2mat(p1);
ip=cell2mat(p2);

d=mean(imat)-mean(nmat);
d0=mean(nip)- mean(ip);

pval=sum(d<d0)/nperm;
display(pval,'p-value permutation test')

%%
if showfig==1
    figure()
    hold on
    ecdf(imat)
    ecdf(nmat)
    legend('info','not info','Location','best')
    
    [h,p_ttest]=ttest2(imat, nmat,'tail','both');
    text(0.1,0.8,['p-val 1 tail ttest=', sprintf('%0.4f',p_ttest)],'units','normalized')
end

%% save result

if saveres==1
    address='/home/veronika/synced/struct_result/pairwise/rsc/rsc_info/';
    filename=['rsc_info_',namea{ba},namep{period}];
    save([address,filename],'imat','nmat','ip','nip','pval')
end

%%
