function [ bac,bacp, C_cv ] = svm_mc_fun(s1,s2,ratio_train_val,ncv,nfold,nperm,Cvec)

%% linear SVM with Monte-Carlo cross-validation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% procedure: (1) find optimal C-parameter, (2) compute the model with MC cross-validations, (3) compute the model with permuted class labels (2000 random permutations)
%
% manipulation of the validation data in step (2): 0 no permutation, 1-permute across features (for every sample),
% 2-permute across samples (for every feature); not to be confused with
% permutation of class labels (step 3)

%% inputs: "s1" and "s2" are spike counts in condition non-match (s1) and match (s2), of the form (number of trials x number of neurons)
% inputs: "ratio_train_val" is the ratio training data/validation data, "ncv" is the number of MOnte-Carlo cross-validations,
% "nfold" is the number of folds for the n-fold cross-validation,
% "nperm" si the number of permutations of class labels, 
% "permute" is the type of permutation for the regular model,
% "Cvec" is the vector of tested C-parameters

% outputs:"bac" is the balanced accuracy, averaged across cros-validations, 
% "bacp" is a vector of balanced accuracies of models with permuted class labels, averaged
% across cross-validations
% "C_cv"  is a vector of regularization parameters in cross-validations

%%
warning('off','all');

n1=size(s1,1); % number of samples condition 1
n2=size(s2,1); % condition 2

ntrain1=floor(n1*ratio_train_val); % nb trials for training condition 1
ntrain2=floor(n2*ratio_train_val); % condition 2

%% normalization

mat=cat(1,s1,s2); 

m=repmat(mean(mat),n1+n2,1);
maxc=repmat(max(mat),n1+n2,1);

matn=(mat-m)./maxc;
s1=matn(1:n1,:);
s2=matn(n1+1:end,:);

%%

label=cat(1,zeros(ntrain1,1),ones(ntrain2,1));              % labels training
label_val=cat(1,zeros(n1-ntrain1,1),ones(n2-ntrain2,1));    % labels validation
N=floor(length(label)/nfold); % number of samples in n-fold cross-validation

%% classify

bac_cv=zeros(ncv,1);
bacp_cv=zeros(ncv,nperm);

C_cv=zeros(ncv,1);
for cv=1:ncv
    
    % permute trial order for Monte-Carlo cross-validation for random
    % splits in training and test set 
    rp1=randperm(n1);
    rp2=randperm(n2);
    
    s1_train=s1(rp1(1:ntrain1),:); % take samples for testing; condition 1
    s2_train=s2(rp2(1:ntrain2),:); % condition 2
    
    train=cat(1,s1_train,s2_train); % concatenate samples condition 1 & condition 2
    
    %%%%%%%%%%%%%%%%%%%%% (1) Find the optimal C-parameter. The search for the optimal
    % C-parameter is done for every Monte Carlo split of the training and
    % validation set.
    % For finding the C-parameter, we use the training set to avoid overfitting. 
    % The training set is split into 10 folds; the model is trained on 9
    % folds and tested on the remaining fold.
    % This is done for every C parameter. After averaging across n-folds, we choose the C parameter that gave the model with best performance. 
    
    new_order=randperm(size(train,1)); % permute order of trials for the n-fold cv 
    s_new=train(new_order,:); 
    label_new=label(new_order);        % use the same order for labels
    
    bac_c=zeros(length(Cvec),nfold);
    for c=1:length(Cvec)                % range of C-parameters
        
        for m=1:nfold
            
            xc_train=[s_new(1:(m-1)*N,:);s_new(m*N + 1 : end,:)];       % data for training
            labc_train=[label_new(1:(m-1)*N);label_new(m * N + 1:end)]; % label training
            
            xc_val=s_new(1+(m-1)*N:m*N,:);                              % data validation
            labc_val=label_new(1+(m-1)*N:m*N);                          % label validation
            
            try
                
                svmstruct=svmtrain(xc_train,labc_train,'kernel_function','linear','boxconstraint',Cvec(c)); % train linear SVM
                class=svmclassify(svmstruct,xc_val); % validate the SVM
                
                tp =length(find(labc_val==1 & class==1)); % TruePos
                tn =length(find(labc_val==0 & class==0)); % TrueNeg
                fp =length(find(labc_val==0 & class==1)); % FalsePos
                fn =length(find(labc_val==1 & class==0)); % FalseNeg
                
                % compute balanced accuracy
                if (tn+fp)==0
                    bac_c(c,m) =tp./(tp+fn); % to avoid NaN
                elseif (tp+fn)==0
                    bac_c(c,m) =tn./(tn+fp); % to avoid NaN
                else
                    bac_c(c,m) =((tp./(tp+fn))+(tn./(tn+fp)))./2;
                end
            catch
                bac_c(c,m)=0;
                
            end
            
        end
    end
    
    [~,idx]=max(mean(bac_c,2)); % average across 10-fold cv and take the max across the tested C-parameters
    C=Cvec(idx);                % choose the regularization parameter with highest accuracy
    C_cv(cv)=C;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %% (2) train and test the model 
  
    s1_val=s1(rp1(ntrain1+1:end),:);                                                                                    % take remaining trials for testing
    s2_val=s2(rp2(ntrain2+1:end),:);
    validate=cat(1,s1_val,s2_val);                                                                                         % concatenate validation data in condition 1 and 2 
   
    	
    try
        
        svmstruct=svmtrain(train,label,'kernel_function','linear','boxconstraint',C); % train
        class=svmclassify(svmstruct,validate); % validate
        
        % get balanced accuracy
        tp =length(find(label_val==1 & class==1)); % TruePos
        tn =length(find(label_val==0 & class==0)); % TrueNeg
        fp =length(find(label_val==0 & class==1)); % FalsePos
        fn =length(find(label_val==1 & class==0)); % FalseNeg
        
        if (tn+fp)==0
            bac_cv(cv)=tp./(tp+fn);
        elseif (tp+fn)==0
            bac_cv(cv)=tn./(tn+fp);
        else
            bac_cv(cv)=((tp./(tp+fn))+(tn./(tn+fp)))./2;
        end
        
    catch
        bac_cv(cv)=0;
    end
    %}
    %% (3) train and test the same data with permutation of labels
    if nperm==0
        continue
    else
        for p=1:nperm
            labelp=label(randperm(length(label)));                                                                              % permutation of  training labels
            try
                
                svmstruct=svmtrain(train,labelp,'kernel_function','linear','boxconstraint',C);
                class=svmclassify(svmstruct,validate);
                
                tp =length(find(label_val==1 & class==1));
                tn =length(find(label_val==0 & class==0)); 
                fp =length(find(label_val==0 & class==1)); 
                fn =length(find(label_val==1 & class==0)); 
                
                if (tn+fp)==0
                    bacp_cv(cv,p)=tp./(tp+fn);
                elseif (tp+fn)==0
                    bacp_cv(cv,p)=tn./(tn+fp);
                else
                    bacp_cv(cv,p)=((tp./(tp+fn))+(tn./(tn+fp)))./2;
                end
                
            catch
                bacp_cv(cv,p)=0;
            end
        end
        
    end
    
end

% average across cv
bac=mean(bac_cv);

if nperm==0
    bacp=NaN;
else
    bacp=mean(bacp_cv);
end


end

