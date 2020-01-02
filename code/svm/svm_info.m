% compute the performance of the linear SVM on spike counts
% in one time window (target or test) and in one brain area (V1 or V4)
% 

close all
clear all
clc
format long

%%%%%%%%%%%
saveres=0;
place=1;                                                                       % 0 for the server, 1 for the office computer

ba=2;                                                                          % brain area: 1 for V1, 2 for V4
period=2;                                                                     
                                                                   
nperm=1000;                                                                       % number of permutations of class labels
ncv=100;                                                                         % number of cross-validations for splits into training and validation set 

Nuse=4;

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1,0.5];                      % range of tested regularization parameters
ratio_train_val=0.8;                                                           % ratio of training/validation data
nfold=10;                                                                      % number of folds for computing the regularization param

start_vec=[200,500];
start=start_vec(period);                                                      % start of the time window
L=500;

namea={'V1','V4'};
namep={'target','test'};
namet={'info','no_info'};

%%

addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/weights_regular/')

if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

sc_all=cellfun(@(x) sum(x(:,:,start:start+L-1),3),spiketrain,'UniformOutput', false);

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                             % load weights of the svm
load(loadname2)


%% classification with linear SVM on the difference of spike counts

tic

bac_inf=zeros(nbses,2);
bac_infp=zeros(nbses,nperm,2);

for su=1:2
    
    display(['computing svm info ', namea{ba},' ',namep{period},' ',namet{su}])
    
    parfor sess=1:nbses
        
        
        w=abs(weight_all{sess});
        [val,idx]=sort(w);                                                      % sort the absolute value of weights (from smallest to bigget)
        
        %%
        if su==1
            idx_use=idx(1:Nuse);                                                % use uninformative neurons
        else
            idx_use=idx(end-Nuse+1:end);                                        % use informative neurons
        end
        
        display(idx_use)
        s1=sc_all{sess,1}(:,idx_use);
        s2=sc_all{sess,2}(:,idx_use);
        
        [bac,bacp,~] = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec);
        
        bac_inf(sess,su)=bac;                                                   % balanced accuracy
        bac_infp(sess,:,su)=bacp;                                               % balanced accuracy of models trained on permuted labels
        
    end
    
end

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/classification/svm_info/';
    filename=['svm_info_', namea{ba},namep{period}];
    save([address, filename],'bac_inf','bac_infp')
end




