% compute the performance of the linear SVM on difference of spike counts
% test - target from parallel spike trains using neurons of one type (+ or - neurons)

close all
clear all
clc
format long

%%%%%%%%%%%

place=1;                                                                        % 0 for the server, 1 for the office computer
ba=1;                                                                           % brain area: 1 for V1, 2 for V4
period=2;

saveres=0;                                                                      % save result?

nperm=1;                                                                        % number of permutations of class labels
ncv=20;                                                                         % number of cross-validations for splits into training and validation set 

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1];                       % range of tested regularization parameters
ratio_train_val=0.8;                                                            % ratio of training/validation data
nfold=10;                                                                       % number of folds for computing the regularization param

%%

namea={'V1','V4'};
namep={'target','test'};
namesign={'minus','plus'};

addpath('/home/veronika/struct_pop/result/input/spike_count/')
addpath('/home/veronika/struct_pop/result/weights/weights_regular/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else    
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname=['sc_',namea{ba},'.mat'];                                            % load spike counts
load(loadname);

if period==1
    sc_all=sc_tar;
else
    sc_all=sc_test;
end

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                       % load w_svm
load(loadname2)

signw=cellfun(@sign, weight_all, 'UniformOutput', false);

%% classify

tic

nbses=size(sc_all,2);
bac_sign=zeros(nbses,2);
bac_signp=zeros(nbses,nperm,2);

for su=1:2
    
    display(['computing svm sign ', namea{ba},' ',namep{period},' ',namesign{su}])
    
    for sess=1:nbses
        
        warning('off','all');

        if su==1
            idx_use=find(signw{sess}<0);                                            % use minus neurons
        else
            idx_use=find(signw{sess}>0);                                            % use plus neurons
        end
        
        if isempty(idx_use)==1
            
            bac_sign(sess,su)=nan;
            bac_signp(sess,:,su)=nan(nperm,1);
        else
            
            s1=sc_all{1,sess}(:,idx_use);
            s2=sc_all{2,sess}(:,idx_use);
            N=size(s1,2);
            
            
            [bac,bacp,~] = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec);
            
            bac_sign(sess,su)=bac;                                                                                         % balanced accuracy
            bac_signp(sess,:,su)=bacp;                                                                                     % balanced accuracy of models trained on permuted labels
            
        end
    end 
end

toc
%% save results

if saveres==1
    address='/home/veronika/struct_pop/result/classification/svm_tartest/sign_specific/';
    filename=['svm_sign_', namea{ba},namep{period}];
    save([address, filename],'bac_sign','bac_signp')
end

