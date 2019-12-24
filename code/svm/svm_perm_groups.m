% compute the performance of the linear SVM spike counts
% uses two groups, + and - neurons; the noise correlation is removed
% between the two groups (but kept within the groups)

close all
clear all
clc
format long

%%%%%%%%%%%
saveres=0;
place=0;                                                                   % 0 for the server, 1 for the office computer

type=2;                                                                    % 1-permute across features (for every sample), % 2-permute across samples (for every feature)
period=2; 

ba=1; 
window=2;

nperm=2;                                                                   % number of permutations of class labels
ncv=10;                                                                    % number of cross-validations for splits into training and validation set 

start_vec=[500,500,750] - 300*(period==1);                                 % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);
      
display([start,start+K],'window')

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1,0.5];              % range of tested regularization parameters
ratio_train_val=0.8;                                                       % ratio of training/validation data
nfold=10;                                                                  % number of folds for computing the regularization param

%%
namea={'V1','V4'};
namep={'target','test'};
namet={'homogeneous','remove_noise'};
namew={'','_first_half','_second_half'};

addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else    
    addpath('/home/veronika/struct_pop/code/function/')
end
%%

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];              % load spike trains
load(loadname);
nbses=size(spiketrain,1);

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                       	% load weights of the linear svm
load(loadname2)

strain_all=cellfun(@(x) single(x(:,:,start:start+K-1)), spiketrain,'UniformOutput',false);
sc_all=cellfun(@(x) sum(x,3), strain_all,'UniformOutput', false);

disp(['computing svm groups ',namet{type},' ', namea{ba},' ',namew{window}(2:end)])

%% classification
tic

bac_all=zeros(nbses,1);
bac_allp=zeros(nbses,nperm);

parfor sess=1:nbses
    
    warning('off','all');
    
    w=weight_all{sess};
    nidx=find(w<0);
    pidx=find(w>0);
    
    sc_sess=sc_all(sess,:);            % get spike counts in session
    s1=sc_sess{1};                     % condition 1
    s2=sc_sess{2};                     % condition 2
    
    if type==1                                                                 % permute across features, independently for every sample (homogenizes data across features)             
        for k=1: size(s1,1)
            s1(k,nidx)=s1(k,randperm(length(nidx)));                           % permute independently for every trial; order_1 for minus neurons; condition non-match                   
            s1(k,pidx)=s1(k,randperm(length(pidx)));                           % order_2 for plus neurons; condition non-match
        end
        for k=1:size(s2,1)
            s2(k,nidx)=s2(k,randperm(length(nidx)));                            % condition match
            s2(k,pidx)=s2(k,randperm(length(pidx)));
        end
    end
    
    if type==2                                                                  % remove noise correlations between neurons with positive and negative weights
        % condition 1
        order_neg=randperm(size(s1,1));                                         % permute the order of trials; order_1 for minus neurons; condition non-match
        order_pos=randperm(size(s1,1));                                         % order_2 for plus neurons; condition non-match
        s1(:,nidx)=s1(order_neg,nidx);
        s1(:,pidx)=s1(order_pos,pidx);
        
        % condition 2
        order_neg=randperm(size(s2,1));                                        % condition match             
        order_pos=randperm(size(s2,1));
        s2(:,nidx)=s2(order_neg,nidx);
        s2(:,pidx)=s2(order_pos,pidx);
        
    end
    
    [bac,bacp,~] = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec);
    bac_allp(sess,:)=bacp;                                                     % balanced accuracy of models trained on permuted labels
    bac_all(sess)=bac;                                                         % balanced accuracy
    
end
toc
%%
display(mean(bac_all),'average balanced accuracy');
%% save results

if saveres==1
    address=['/home/veronika/synced/struct_result/classification/svm_',namet{type},'/'];
    filename=['svm_groups_',namet{type},'_', namea{ba},namep{period},namew{window}];
    save([address, filename],'bac_all','bac_allp')
    clear all
end


