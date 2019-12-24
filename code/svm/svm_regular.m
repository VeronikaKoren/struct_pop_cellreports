% compute the performance of the linear SVM on spike counts
% in one time window (target or test) and in one brain area (V1 or V4)

close all
clear all
clc
format long

%%%%%%%%%%%
saveres=0;                                                                    % save result?
place=1;                                                                      % 0 for the server, 1 for the office computer

type=1;
period=2;

ba=2;                                                                         % brain area: 1 for V1, 2 for V4                                                                     % type of model: 1~ regular model, 2-permute sc across features (for every sample), % 3-permute across samples (for every feature); for more details, look inside the function svm_mc_fun
window=1;

nperm=2;                                                                     % number of permutations of class labels
ncv=20;                                                                      % number of cross-validations for splits into training and validation set 

%%

start_vec=[500,500,750] - 300*(period==1);                                   % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);
                                                                             % length of the time window
Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1,0.5];                 % range of tested regularization parameters
ratio_train_val=0.8;                                                          % ratio of training/validation data
nfold=10;                                                                     % number of folds for computing the regularization param

namea={'V1','V4'};
namep={'target','test'};
nameperm={'regular','homogeneous','remove_noise'};
namew={'','_first_half','_second_half'};

display([start,start+K],'window')
%%

addpath('/home/veronika/synced/struct_result/input/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/function/')
end

loadname=['spike_train_choice_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

strain_all=cellfun(@(x) single(x(:,:,start:start+K-1)), spiketrain,'UniformOutput',false);
sc_all=cellfun(@(x) sum(x,3), strain_all,'UniformOutput', false);
display(['computing svm on spike counts in ', namea{ba},' ',namep{period},' ',nameperm{type}])

%% classification with linear SVM on the difference of spike counts

tic

bac_all=zeros(nbses,1);
bac_allp=zeros(nbses,nperm);

parfor sess=1:nbses
    
    sc_sess=sc_all(sess,:);                                             % get spike trains in session
    s1=sc_sess{1};                     % get time window and count spikes; condition 1
    s2=sc_sess{2};                     % condition 2
    
    N=size(s1,2);
    
    if type==2 % permute across features, independently for every sample (homogenizes data across features)
        for k=1: size(s1,1)
            s1(k,:)=s1(k,randperm(N));
        end
        for k=1:size(s2,1)
            s2(k,:)=s2(k,randperm(N));
        end
    end
    
    if type==3 % permute across samples, independently for every feature (removes noise correlations across units)
        for j=1:N
            s1(:,j) = s1(randperm(size(s1,1)),j);
            s2(:,j) = s2(randperm(size(s2,1)),j);
        end
    end
    
    [bac,bacp,~] = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec);
    %display(bac)
    
    bac_allp(sess,:)=bacp;                                                          % balanced accuracy of models trained on permuted labels
    bac_all(sess)=bac;                                                              % balanced accuracy
    
end

%%
display(mean(bac_all),'mean BAC')

%% save results

if saveres==1
    %address=['/home/veronika/synced/struct_result/classification/svm_',nameperm{type},'/'];
    address='/home/veronika/synced/struct_result/classification/svm_stim/';
    filename=['svm_',nameperm{type},'_',namea{ba},namep{period},namew{window}];
    save([address, filename],'bac_all','bac_allp','start','K')
end




