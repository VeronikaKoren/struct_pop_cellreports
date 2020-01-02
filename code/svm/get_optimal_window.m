% compute performance of a linear SVM as a function of the starting time
% and the length of the time window

close all
clear all
clc
format long

%%%%%%%%%%%
                                                                    
place=1;                                                                       % 0 for the server, 1 for the office computer
ba=1;                                                                          % brain area: 1 for V1, 2 for V4
period=2;                                                                      % time period: 1 for target, 2 for test

if place==0
    saveres=1;                                                                  % save result?
else
    saveres=1;
end

ncv=100;                                                                        % number of cross-validations for splits into training and validation set 
Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1,0.5];                  % range of tested regularization parameters
ratio_train_val=0.8;                                                           % ratio of training/validation data
nfold=10;                                                                      % number of folds for computing the regularization param

namea={'V1','V4'};
namep={'target','test'};

%%

addpath('/home/veronika/synced/struct_result/input/spike_train/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                                            % load difference of spike counts
load(loadname);

%%
start_vec=[500,600,700,800,900];
L_vec=[500,400,300,200,100];

nbses=size(spiketrain,1);

display(['get best time window in ', namea{ba}])

%% classification with linear SVM on the difference of spike counts

tic

bac_w=zeros(length(start_vec),length(L_vec),nbses);
for i=1:length(start_vec)
    
    start=start_vec(i);
        
    for j=i:length(L_vec)
        L=L_vec(j);
        
        bac_sess=zeros(nbses,1);
        parfor sess=1:nbses
            
            spikes_sess=spiketrain(sess,:);                                             % get session
            
            s1=squeeze(sum(spikes_sess{1}(:,:,start:start+L-1),3));                       % get time window and count spikes; condition 1
            s2=squeeze(sum(spikes_sess{2}(:,:,start:start+L-1),3));                       % condition 2
            N=size(s1,2);
            
            bac = svm_simple_fun(s1,s2,ratio_train_val,ncv,nfold,Cvec);
            bac_sess(sess)=bac;
            
        end
        
        bac_w(i,j,:)=bac_sess;
        
    end
    
end

toc


%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/classification/svm_window/';
    filename=['get_window_', namea{ba}];
    save([address, filename],'bac_w','start_vec','L_vec')
end




