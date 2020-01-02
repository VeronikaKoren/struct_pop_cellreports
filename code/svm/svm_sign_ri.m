% compute the performance of the linear SVM on sign-specific model: extract
% the permformance of a specific group of neurons by replacing the input of the other
% group with activity from a randomly selected trial

close all
clear all
clc
format long

%%%%%%%%%%%

place=1;                                                                        % 0 for the server, 1 for the office computer
ba=1;                                                                           % brain area: 1 for V1, 2 for V4
period=2;

saveres=0;                                                                      % save result?

nperm=1000;                                                                        % number of permutations 
ncv=100;                                                                         % number of cross-validations for splits into training and validation set 

%%

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1];                       % range of tested regularization parameters
ratio_train_val=0.8;                                                            % ratio of training/validation data
nfold=10;                                                                       % number of folds for computing the regularization param

start_vec=[200,500];
start=start_vec(period);                                                      % start of the time window
K=500; 

%%
namea={'V1','V4'};
namep={'target','test'};
names={'minus','plus'};

addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else    
    addpath('/home/veronika/struct_pop/code/function/')
end
%%

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

strain=cellfun(@(x,y) single(x(:,:,start:start+K-1)),spiketrain, 'UniformOutput', false);
sc_all=cellfun(@(x) squeeze(sum(x,3)) ,strain, 'UniformOutput',false);

%% load weights

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                       	% load w_svm
load(loadname2)

signw=cellfun(@sign, weight_all, 'UniformOutput', false);

%% classify

display(['computing svm sign ri ', namea{ba},' ',namep{period}])

tic

bac_sign=cell(nbses,1);

oarfor sess=1:nbses
   
    sc_sess=sc_all(sess,:); % 2 conditions
    sc_one=cat(1,sc_sess{1},sc_sess{2}); % 1 condition; concatenated
    
    N=size(sc_one,2);
    J_tot=size(sc_one,1);
    J=cellfun(@(x) size(x,1),sc_sess);
    
    bac_s=zeros(2,nperm);
    for sgn=1:2

        if sgn==1
            idx_keep=find(signw{sess}<0);                                            % use minus neurons
        else
            idx_keep=find(signw{sess}>0);                                            % use plus neurons
        end
        
        for perm=1:nperm
           
            sc_perm=sc_one(randperm(J_tot),:,:);                                    % random permutation of the trial order
            sc_perm(:,idx_keep)=sc_one(:,idx_keep);                                 % selected group has correct order
            s1=sc_perm(1:J(1),:);
            s2=sc_perm(J(1)+1:end,:);
            [bac] = svm_simple_fun(s1,s2,ratio_train_val,ncv,nfold,Cvec);
            
            bac_s(sgn,perm)=bac;                                                    % balanced accuracy
        end                                                                         % balanced accuracy of models trained on permuted labels
         
    end
    
    bac_sign{sess}=bac_s;
end

toc

%%
bac_minus=cellfun(@(x) x(1,:)',bac_sign,'UniformOutput', false);
bac_plus=cellfun(@(x) x(2,:)',bac_sign,'UniformOutput', false);

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/classification/svm_sign/';
    filename=['svm_sign_', namea{ba},namep{period}];
    save([address, filename],'bac_sign','K','start')
end

