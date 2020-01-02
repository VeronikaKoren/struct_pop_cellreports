% compute mean and variance of spike counts for informative and less informative neurons

clear all
close all
clc

saveres=0;
showfig=1;


period=2;
ba=2;
window=3;

nperm=1000;

%%
namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

start_vec=[500,500,750] - 300*(period==1);                                    % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);

display([start,start+K],'window')

%% load 

addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/tag/')

loadname=['spike_train_',namea{ba},'_',namep{period}];                          
load(loadname)

loadname3=['tag_info_', namea{ba},namep{period},namew{window}];         % load tag informative neurons in the right window
load(loadname3)

%% compute mean and std of spike counts

% use both conditions
strain_all=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))), spiketrain(:,1),spiketrain(:,2),'UniformOutput',false);
nbses=length(strain_all);

dt=1/1000;
sc=cellfun(@(x) squeeze(sum(x,3))./(K*dt),strain_all,'UniformOutput',false); % spike counts in trials

msc=cellfun(@(x) (mean(x))',sc,'UniformOutput',false);                       % spike count, mean across trials           
msc_vec=double(cell2mat(msc));

stdsc=cellfun(@(x) (std(x))',sc,'UniformOutput',false);                       % variance across trials
std_vec=double(cell2mat(stdsc));

%%
idxi=find(cell2mat(tag_info)');
idxn=find(cell2mat(tag_info)==0)';

%% firing rate

msci=cell(2,1);
msci{1}=msc_vec(idxi);
msci{2}=msc_vec(idxn);

ni=cellfun(@length,msci);
N=sum(ni);
% permutation test firing rate

p1=zeros(ni(1),nperm);
p2=zeros(ni(2),nperm);

for perm=1:nperm
    rp=randperm(N);
    msc_ran=msc_vec(rp);
    p1(:,perm)=msc_ran(1:ni(1));
    p2(:,perm)=msc_ran(ni(1)+1:end);
end

d=mean(msci{1})-mean(msci{2});
d0=mean(p1)-mean(p2);

pval_fr=sum(d<d0)/nperm;

%% standard deviation of spike counts

stdi=cell(2,1);
stdi{1}=std_vec(idxi);
stdi{2}=std_vec(idxn);

p1=zeros(ni(1),nperm);
p2=zeros(ni(2),nperm);

for perm=1:nperm
    rp=randperm(N);
    ran=std_vec(rp);
    p1(:,perm)=ran(1:ni(1));
    p2(:,perm)=ran(ni(1)+1:end);
end

d=mean(stdi{1})-mean(stdi{2});
d0=mean(p1)-mean(p2);

pval_std=sum(d<d0)/nperm;

%%

display(pval_fr,'p-val perm test fr')
display(pval_std,'p-val perm test std')

%%

if showfig==1
    figure()
    subplot(2,1,1)
    title('mean')
    hold on
    ecdf(msci{1})
    ecdf(msci{2})
    
    subplot(2,1,2)
    title('standard deviation')
    hold on
    ecdf(stdi{1})
    ecdf(stdi{2})
    
end

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/stats/';
    filename=['stats_info_',namea{ba},namep{period},namew{window}];
    save([address, filename],'msci','stdi','pval_fr','pval_std')
end


