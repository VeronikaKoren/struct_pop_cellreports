% compute performance of a linear SVM for the first and second half of the
% trial

close all
clear all
clc
format short

%%%%%%%%%%%
                                                                    
place=1;                                                              % 0 for the server, 1 for the office computer
ba=2;                                                                 % brain area: 1 for V1, 2 for V4
period=2;                                                             % time period: 1 for target, 2 for test
type=2;                                                               % 1 for regular, 2 for permuted class labels  

if place==0
    saveres=0;                                                         % save result?
else
    saveres=0;
end

if type==2
    nperm=1000;
end

ncv=100;                                                                 % number of cross-validations for splits into training and validation set 
Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1,0.5];            % range of tested regularization parameters
ratio_train_val=0.8;                                                     % ratio of training/validation data
nfold=10;                                                                % number of folds for computing the regularization param

namea={'V1','V4'};
namep={'target','test'};
namet={'regular','permuted'};

%%

addpath('/home/veronika/synced/struct_result/input/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                                            % load difference of spike counts
load(loadname);

%%
start_vec=[500,750];
L=250;
nbses=size(spiketrain,1);

display(['half time window in ', namea{ba},' ', namet{type}])

%% classification with linear SVM on the difference of spike counts

if type==1
    bac_halfw=zeros(length(start_vec),nbses);
else
    bac_halfwp=zeros(length(start_vec),nbses,nperm);
end

tic

for ii=1:length(start_vec)
    
    start=start_vec(ii);
    
    if type ==1
        bac_sess=zeros(nbses,1);
    else
        bac_sessp=zeros(nbses,nperm);
    end
    
    parfor sess=1:nbses
        
        spikes_sess=spiketrain(sess,:);                                             % get session
        
        s1=squeeze(sum(spikes_sess{1}(:,:,start:start+L-1),3));                       % get time window and count spikes; condition 1
        s2=squeeze(sum(spikes_sess{2}(:,:,start:start+L-1),3));                       % condition 2
        N=size(s1,2);
        
        if type==1
            bac = svm_simple_fun(s1,s2,ratio_train_val,ncv,nfold,Cvec);
            bac_sess(sess)=bac;
        else
            [ ~,bacp, ~ ] = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec)
            bac_sessp(sess,:)=bacp;
        end
    end
    
    if type==1
        bac_halfw(ii,:)=bac_sess;
    else
        bac_halfwp(ii,:,:)=bac_sessp;
    end
end

toc

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/classification/svm_window/';
    filename=['half_window_',namet{type}, namea{ba}];
    if type==1
        save([address, filename],'bac_halfw','start_vec','L')
    else
        save([address, filename],'bac_halfwp','start_vec','L')
    end
end
