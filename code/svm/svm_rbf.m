% compute the performance of with non-linear SVM with RBF kernel on spike counts
% in one time window (target or test) and in one brain area (V1 or V4)

close all
%clear all
clc
format long

%%%%%%%%%%%

place=1;                                                                       % 0 for the server, 1 for the office computer
ba=1;                                                                          % brain area: 1 for V1, 2 for V4
period=2;

saveres=0;                                                                     % save result?

nperm=1000;                                                                       % number of permutations of class labels
ncv=100;                                                                         % number of cross-validations for splits into training and validation set 

%%
ratio_train_val=0.8;                                                           % ratio of training/validation data
nfold=10;                                                                      % number of folds for computing the regularization param
Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1,1,5];                     % range of tested regularization parameters
sigma_range=[1,10,100,200,350,500,1000,2000,5000];
start_vec=[200,500];
start=start_vec(period);

namea={'V1','V4'};
namep={'target','test'};

%%

addpath('/home/veronika/synced/struct_result/input/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

nbses=size(spiketrain,1);
display(['computing svm with RBF kernel ', namea{ba},' ',namep{period}])

%% classification with linear SVM on the difference of spike counts

tic

bac_all=zeros(nbses,1);
bac_allp=zeros(nbses,nperm);

parfor sess=1:nbses
    
    warning('off','all');

    spikes_sess=spiketrain(sess,:);                                             % get spikes in session    
    s1=squeeze(sum(spikes_sess{1}(:,:,start:start+L-1),3));                     % get time window and count spikes; condition 1
    s2=squeeze(sum(spikes_sess{2}(:,:,start:start+L-1),3));
    
    [bac,bacp,C_cv, sigma_cv] = svm_nonlinear_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec,sigma_range);
    display(bac)
    
    bac_allp(sess,:)=bacp;                                                             % balanced accuracy of models trained on permuted labels
    bac_all(sess)=bac;                                                                 % balanced accuracy
    
end

toc

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/classification/svm_rbf/';
    filename=['svm_rbf_', namea{ba},namep{period}];
    save([address, filename],'bac_all','bac_allp')
end
%}



