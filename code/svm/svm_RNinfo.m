% SVM with removed correlation within informative/uninformative group

close all
clear all
clc
format long

%%%%%%%%%%%

place=1;                                                                       % 0 for the server, 1 for the office computer
saveres=0;
showfig=1;

ba=2;                                                                          % brain area: 1 for V1, 2 for V4
period=2;
                                                                     
ncv=50;                                                                       % number of cross-validations for splits into training and validation set 
npermn=1;                                                                      % permutation of neural index 
nperm=0;                                                                       % number of permutations of class labels

Cvec=[0.0012,0.00135,0.0015,0.002,0.005,0.01, 0.05, 0.1];                      % range of tested regularization parameters
ratio_train_val=0.8;                                                           % ratio of training/validation data
nfold=10;                                                                      % number of folds for computing the regularization param

start_vec=[200,500];
start=start_vec(period);                                                      % start of the time window
L=500;                                                                        
%%

namea={'V1','V4'};
namep={'target','test'};

addpath('/home/veronika/struct_pop/result/input/')
addpath('/home/veronika/struct_pop/result/weights/weights_regular/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/function/')
end

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

sc_all=cellfun(@(x) sum(x(:,:,start:start+L-1),3),spiketrain,'UniformOutput', false);

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                       % load w_svm
load(loadname2)

display(['classification with removed noise correlations between informative neurons ', namea{ba},' ',namep{period}])

%% classification with linear SVM on the difference of spike counts

tic

bac_removei=zeros(nbses,1);
bac_removeni=zeros(nbses,1);
bac_perm=zeros(nbses,npermn);


parfor sess=1:nbses
    
    disp(sess)
    warning('off','all');
    
    
    w=abs(weight_all{sess});
    [~,idx]=sort(w);
    
    % permute trial index between informative neurons
    s1o=sc_all{sess,1};
    s2o=sc_all{sess,2};
    N=size(s1o,2);
    Nh=floor(N/2);
    
    idx_info=idx(end-Nh+1:end);
    s1=s1o;
    s2=s2o;
    
    for i=1:Nh
        s1(:,idx_info(i)) = s1(randperm(size(s1,1)) , idx_info(i));             % permute trial order for each informative neuron independently                
        s2(:,idx_info(i)) = s2(randperm(size(s2,1)) , idx_info(i));
    end    
    bac_removei(sess) = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec);
    
    %% permute trial index between uninformative neurons
    idx_notinfo=idx(1:Nh);
    s1=s1o;
    s2=s2o;
    
    for i=1:Nh
        s1(:,idx_notinfo(i)) = s1(randperm(size(s1,1)) , idx_notinfo(i));        % permute trial order for each uninformative neuron independently
        s2(:,idx_notinfo(i)) = s2(randperm(size(s2,1)) , idx_notinfo(i));
    end    
    bac_removeni(sess) = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec);

    %%%%%%%%%%%%%%% 
    %% randomly select neurons and remove correlations
    %{
    for perm=1:npermn
        
        s1=s1o;
        s2=s2o;
        
        random_order=randperm(N);                                               % permute the neural index
        idxp=random_order(1:Nuse);                                              % use Nuse randomly selected neurons
        
        for i=1:Nuse
            s1(:,idxp(i)) = s1(randperm(size(s1,1)) , idxp(i));                 % permute the trial order of randomly selected neurons
            s2(:,idxp(i)) = s2(randperm(size(s2,1)) , idxp(i));
        end
        
        bac_perm(sess,perm) = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec);
    end
    %}                                                                           
end
toc
%%

mean(bac_removei)
mean(bac_removeni)
%mean(mean(bac_perm))

%%
if showfig==1
    [val,order]=sort(bac_removei);
    new_order=flip(order)
    
    figure()
    plot(bac_removei(new_order),'r')
    hold on
    plot(bac_removeni(new_order),'b')
    %plot(mean(bac_perm,2),'kx')
    legend('remove corr across info','remove corr across not info')
    
end
%% save results

if saveres==1
    address='/home/veronika/synced/struct_pop/result/classification/svm_remove_noise/';
    filename=['svm_rn_selected_', namea{ba},namep{period}];
    save([address, filename],'bac_removegood','bac_removebad','bac_perm')
    clear all
end



