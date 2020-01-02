% computes the area under the ROC curve (auc score) of single neurons 
% uses spike counts in conditions correct match and non-match 
% computes the regular auc score (1 per neuron) and the auc score  with permuted class labels (nperm auc scores for each single neuron) 

close all
clear all
clc
format long

saveres=0;                                                                     % save result?

ba=1;                                                                          % brain area; 1 for V1 and 2 for V4
period=2;

nperm=1000;                                                                    % number of permutation of class labels

%%

namea={'V1','V4'};
namep={'target','test'};

addpath('/home/veronika/Dropbox/struct_pop/code/function/')
addpath('/home/veronika/synced/struct_result/input/')

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);

%%
start_vec=[200,500];
start=start_vec(period);                                                      % start of the time window
L=500;

sc_all=cellfun(@(x) sum(x(:,:,start:start+L-1),3),spiketrain,'UniformOutput',false)';

%%
% maximum absolute sc
cat_sc=cellfun(@(x,y) cat(1,x,y), sc_all(1,:), sc_all(2,:),'UniformOutput', false); 
maxy_cell=cellfun(@(x) max(abs(x)), cat_sc, 'UniformOutput', false);
maxi=max(cell2mat(maxy_cell));
xvec=linspace(0,maxi,200);                                                % support for the probability distribution (used for computing the area under the ROC curve)

%% compute area under the curve for spike counts

nbses=size(sc_all,2);
auc=cell(nbses,1);
auc_perm=cell(nbses,1);

tic
disp(['computing auc score in ', namea{ba},' ', namep{period}])

                                                                     
parfor sess=1:nbses                                                        % across recording sessions
  
    N=size(sc_all{1,sess},2);                                              % number of cells in a session 
    
    auc_collect=zeros(N,1);
    a_perm=zeros(N,nperm);
        
    for i=1:N                                                              % across cells in a session
            
        data1=sc_all{1,sess}(:,i);                                           % spike counts condition 1 
        data2=sc_all{2,sess}(:,i);                                           % condition 2 
     
        [auc_score, bw] = get_auc_all_trials(data1,data2,xvec);             % computes the area under the ROC curve
        auc_collect(i)=auc_score;                                           % collect across neurons
        a_perm(i,:)= get_auc_permuted_all_tr( data1,data2, xvec,bw,nperm ); % auc with permutation of labels
        
    end
             
    auc{sess}=auc_collect;
    auc_perm{sess}=a_perm;
        
end
    

toc
%%

if saveres==1
    address='/home/veronika/synced/struct_result/classification/auc_regular/';
    filename=['auc_',namea{ba},namep{period}];
    save([address, filename],'auc','auc_perm')
end
