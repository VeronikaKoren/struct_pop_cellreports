% compute the performance of the linear SVM on sign-specific model: extract
% the permformance of a specific group by replacing the input of the other
% group with activity from a randomly selected trial
% remove the effect of all informative neurons at once

close all
clear all
clc
format long

%%%%%%%%%%%

place=1;                                                                        % 0 for the server, 1 for the office computer
saveres=0;                                                                      % save result?

ba=2;                                                                           % brain area: 1 for V1, 2 for V4
period=2;

nperm=2;                                                                        % number of permutations 
ncv=5;                                                                         % number of cross-validations for splits into training and validation set 

%%

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1];                       % range of tested regularization parameters
ratio_train_val=0.8;                                                            % ratio of training/validation data
nfold=5;                                                                       % number of folds for computing the regularization param

start_vec=[200,500];
start=start_vec(period);                                                      % start of the time window
K=500; 

%% addpath

namea={'V1','V4'};
namep={'target','test'};

addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/tag/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else    
    addpath('/home/veronika/struct_pop/code/function/')
end

%% load 

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

strain=cellfun(@(x,y) single(x(:,:,start:start+K-1)),spiketrain, 'UniformOutput', false);
sc_all=cellfun(@(x) squeeze(sum(x,3)) ,strain, 'UniformOutput',false);

loadname2=['tag_info_',namea{ba},namep{period},'.mat'];                       % load w_svm
load(loadname2)

%% classify

display(['computing svm info ri ', namea{ba},' ',namep{period}])

tic

bac_ri=cell(nbses,1);

parfor sess=1:nbses
   
    sc_sess=sc_all(sess,:); % 2 conditions
    sc_one=cat(1,sc_sess{1},sc_sess{2}); % 1 condition; concatenated
    
    N=size(sc_one,2);
    J_tot=size(sc_one,1);
    J=cellfun(@(x) size(x,1),sc_sess);
    
    bac_s=zeros(2,nperm);
    
    %%
    
    for i=1:2
        
        tag=double(tag_info{sess});
        idx_keep=1:N;
        if i==1
            idx_i=find(tag);                                                    % index of informative neurons
        else
             idx_i=find(tag==0);                                                % idx of uninformative neurons
        end
        
        idx_keep(idx_i)=[];                                                     % remove informative or uninformative neurons
        
        for perm=1:nperm
            
            sc_perm=sc_one(randperm(J_tot),:,:);                                    % random permutation of the trial order
            sc_perm(:,idx_keep)=sc_one(:,idx_keep);                                 % selected group has correct order
            s1=sc_perm(1:J(1),:);
            s2=sc_perm(J(1)+1:end,:);
            [bac] = svm_simple_fun(s1,s2,ratio_train_val,ncv,nfold,Cvec);
            bac_s(i,perm)=bac;                                                        % balanced accuracy
        end
        
    end
    bac_ri{sess}=bac_s;
    
end

toc

%%

bac_noinfo=cellfun(@(x) x(1,:)',bac_ri,'UniformOutput', false);
bac_info=cellfun(@(x) x(2,:)',bac_ri,'UniformOutput', false);

mi=mean(cell2mat(bac_info));
mn=mean(cell2mat(bac_noinfo));

display([mi,mn],'mean bac info/not info');

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/classification/svm_info/';
    filename=['svm_ri_', namea{ba},namep{period}];
    save([address, filename],'bac_info','bac_noinfo','K','start')
end

