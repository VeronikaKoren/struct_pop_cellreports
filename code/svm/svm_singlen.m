% computes SVM on the difference of spike counts test-target in single neurons

close all
clear all
clc

place=1;
saveres=0;

ba=2;
period=2; 

ncv=100;                                                                      % number of cross-validations 

namea={'V1','V4'};
namep={'target','test'};
display(['compute svm of single neurons in ' namea{ba},' during ', namep{period}])

start_vec=[200,500];
start=start_vec(period);                                                      % start of the time window
L=500;  

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1];                       % range of tested regularization parameters                                          
ratio_train_val=0.8;                                                            % ratio of training/validation data
nfold=10;                                                                       % number of folds for computing the regularization paramete

%% load data

addpath('/home/veronika/synced/struct_result/input/')

if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else    
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

%% classify
  
bac_all=cell(nbses,1);

parfor sess=1:nbses
    
    x1=sc_all{1,sess}; % spike counts condition 1
    x2=sc_all{2,sess}; % condition 2
    
    N=size(x1,2);
    
    bacn=zeros(N,1);
    for i=1:N
        s1=x1(:,i); % take spike trains of a single neuron
        s2=x2(:,i);
        
        [bac,~ ] = svm_singlen_fun(s1,s2,ratio_train_val,ncv,nfold,Cvec); % computes classification performance for single neuron
        bacn(i)=bac;
    end
    
    bac_all{sess}=bacn;
    
end

%% save result

if saveres==1
    address='/home/veronika/synced/struct_result/classification/svm_singlen/';
    filename=['svm_singlen_' namea{ba},namep{period}];
    save([address, filename],'bac_all')
end






