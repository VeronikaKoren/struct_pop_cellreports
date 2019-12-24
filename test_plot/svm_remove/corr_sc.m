close all
clear all
%clc
format long

%%%%%%%%%%%
saveres=0;
place=1;                                                                       % 0 for the server, 1 for the office computer

ba=2;                                                                          % brain area: 1 for V1, 2 for V4
period=2;                                                                      % time window: 1 for target, 2 for test     

type=1;                                                                        % 1-permute across features (for every sample), % 2-permute across samples (for every feature); for more details, look inside the function svm_mc_fun
                                                                    
nperm=0;                                                                       % number of permutations of class labels
ncv=100;                                                                         % number of cross-validations for splits into training and validation set 

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1,0.5];                  % range of tested regularization parameters
ratio_train_val=0.8;                                                           % ratio of training/validation data
nfold=10;                                                                      % number of folds for computing the regularization param

%%
namea={'V1','V4'};
namep={'target','test'};
namet={'homogeneous','rnap'};

addpath('/home/veronika/struct_pop/result/input/spike_count/')
addpath('/home/veronika/struct_pop/result/weights/weights_regular/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else    
    addpath('/home/veronika/struct_pop/code/function/')
end
%%
loadname=['sc_',namea{ba},'.mat'];                                            % load spike counts
load(loadname);

if period==1
    sc_all=sc_tar;
else
    sc_all=sc_test;
end

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                       % load w_svm
load(loadname2)

disp(['computing svm ',namet{type},' ', namea{ba},' ',namep{period}])

%% represent data in 2D

nbses=size(sc_all,2);
bac_all=zeros(nbses,1);
%bac_allp=zeros(nbses,nperm);

sess=1;

mat0=sc_all{1,sess};
mat1=sc_all{1,sess};
N=size(mat1,2);
J=size(mat1,1);

for j=1: J
    mat1(j,:)=mat1(j,randperm(N));
end

mat0n=(mat0-repmat(mean(mat0),J,1))./repmat(var(mat0),J,1);
mat1n=(mat1-repmat(mean(mat1),J,1))./repmat(var(mat1),J,1);

C0=(mat0n'*mat0n)./J;
C1=(mat1n'*mat1n)./J;

figure()
subplot(2,2,1)
imagesc(mat0)
colormap pink
colorbar

subplot(2,2,2)
imagesc(mat1)
colormap pink
colorbar

subplot(2,2,3)
imagesc(C0)
colormap pink
colorbar

subplot(2,2,4)
imagesc(C1)
colormap pink
colorbar
%}


%% save results
%{
if saveres==1
    address='/home/veronika/struct_pop/result/classification/svm_tartest/rnap_homogeneous/';
    filename=['svm_',namet{type},'_', namea{ba},namep{period}];
    save([address, filename],'bac_all','bac_allp')
    %clear all
end
%}
%%







