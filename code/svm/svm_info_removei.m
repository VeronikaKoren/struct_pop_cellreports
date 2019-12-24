% compute the performance of the linear SVM on sign-specific model: extract
% the permformance of a specific group by replacing the input of the other
% group with activity from a randomly selected trial
% remove the effect of informative neurons, starting from the most
% informative and adding neurons one by one

close all
clear all
clc
format long

%%%%%%%%%%%

place=1;                                                                        % 0 for the server, 1 for the office computer
saveres=0;                                                                      % save result?

ba=1;                                                                           % brain area: 1 for V1, 2 for V4
period=2;

nperm=20;                                                                        % number of permutations 
ncv=10;                                                                         % number of cross-validations for splits into training and validation set 

%%

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1];                       % range of tested regularization parameters
ratio_train_val=0.8;                                                            % ratio of training/validation data
nfold=10;                                                                       % number of folds for computing the regularization param

start_vec=[200,500];
start=start_vec(period);                                                      % start of the time window
K=500; 

%% addpath

namea={'V1','V4'};
namep={'target','test'};

addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/tag/')
addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else    
    addpath('/home/veronika/struct_pop/code/function/')
end

%% load spike trains

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

strain=cellfun(@(x,y) single(x(:,:,start:start+K-1)),spiketrain, 'UniformOutput', false);
sc_all=cellfun(@(x) squeeze(sum(x,3)) ,strain, 'UniformOutput',false);

%% load tags of info neurons

loadname2=['tag_info_',namea{ba},namep{period},'.mat'];                       % load w_svm
load(loadname2)

loadname3=['svmw_',namea{ba},namep{period},'.mat'];                       % load w_svm
load(loadname3)

%% classify

display(['computing svm info ri ', namea{ba},' ',namep{period}])

tic

bac_removei=cell(nbses,1);

for sess=1:2%:nbses
   
    sc_sess=sc_all(sess,:); % 2 conditions
    sc_one=cat(1,sc_sess{1},sc_sess{2}); % 1 condition; concatenated
    %%
    tag=double(tag_info{sess});
    w=weight_all{sess};
    w_info=w.*tag';
    [~,idx]=sort(w_info);
    idx_strong=fliplr(idx);  % informative neurons from strongest to weakest
    
    n=sum(tag);
    
    N=size(sc_one,2);
    J_tot=size(sc_one,1);
    J=cellfun(@(x) size(x,1),sc_sess);
    %%
    
    bac_s=zeros(n,nperm);
    for i=1:n
        idx_remove=idx_strong(1:n);
        
        for perm=1:nperm
            sc_use=sc_one;
            sc_perm=sc_one(randperm(J_tot),:,:);                                    % random permutation of the trial order
            sc_use(:,idx_remove)=sc_perm(:,idx_remove);                             % neurons with idx remove get permuted trials
            %sc_perm(:,idx_keep)=sc_one(:,idx_keep);                                 % selected group has correct order
            s1=sc_use(1:J(1),:);
            s2=sc_use(J(1)+1:end,:);
            [bac] = svm_simple_fun(s1,s2,ratio_train_val,ncv,nfold,Cvec);
            
            bac_s(i,perm)=bac;                                                    % balanced accuracy
        end                                                                         % balanced accuracy of models trained on permuted labels
         
    end
    
    bac_removei{sess}=bac_s;
    %}
end

toc


%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/classification/svm_info/';
    filename=['svm_removei_', namea{ba},namep{period}];
    save([address, filename],'bac_removei','K','start')
end

