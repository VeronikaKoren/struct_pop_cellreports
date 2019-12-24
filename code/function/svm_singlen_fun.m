function [ bac,Ccv ] = svm_singlen_fun(s1,s2,ratio_train_val,ncv,nfold,Cvec)

%% linear SVM with Monte-Carlo cross-validation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selects the C parameter on the training set with 10-fold crossvalidation
% trains and tests the linear svm with Monte-Carlo cross-validation (100 random splits into train and test set)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off','all');

n1=size(s1,1); % number of samples condition 1
n2=size(s2,1); % condition 2

s_all=cat(1,s1,s2);                                                  % center and normalize (z-score)
ma=mean(s_all);
stda=std(s_all);

s_norm=(s_all-ma)./stda;
s1=s_norm(1:n1);
s2=s_norm(n1+1:end);

%%

ntrain1=floor(n1*ratio_train_val); % number of samples in condition 1 to be used for training
ntrain2=floor(n2*ratio_train_val);  % number of samples in condition 2 to be used for training

label=cat(1,zeros(ntrain1,1),ones(ntrain2,1)); % labels training 
label_val=cat(1,zeros(n1-ntrain1,1),ones(n2-ntrain2,1)); % labels validation 
N=floor(length(label)/nfold); % number of samples in n-fold cross-validation

%%%%%%%%%%%%%%%%%%%%%%%%%% estimate C-parameter, compute the model with MC cross-validations %%%%%%%%%%%%%555555

bac_cv=zeros(ncv,1);
Ccv=zeros(ncv,1);
for cv=1:ncv
    
    % permute trial order for cross-validation
    rp1=randperm(n1);
    rp2=randperm(n2);
    
    s1_train=s1(rp1(1:ntrain1),:); % take ratio of the trials for testing; condition 1
    s2_train=s2(rp2(1:ntrain2),:); % condition 2
    
    train=cat(1,s1_train,s2_train); % concatenate condition 1 & condition 2
    
    %%%%%%%%%%%%%%%%%%%%% use training set to find the C-parameter
    
    new_order=randperm(size(train,1));
    s_new=train(new_order,:); % permute order for 10-fold cv
    label_new=label(new_order);
    
    bac_c=zeros(length(Cvec),nfold);
    for c=1:length(Cvec) % range of C-parameters
        
        for m=1:nfold
            
            xc_train=[s_new(1:(m-1)*N,:);s_new(m*N + 1 : end,:)];       % data for training
            labc_train=[label_new(1:(m-1)*N);label_new(m * N + 1:end)]; % labels training
            
            xc_val=s_new(1+(m-1)*N:m*N,:);                              % data for validation
            labc_val=label_new(1+(m-1)*N:m*N);                          % labels validation
            
            try
                
                svmstruct=svmtrain(xc_train,labc_train,'kernel_function','linear','boxconstraint',Cvec(c));% train the svm
                class=svmclassify(svmstruct,xc_val); % vaidate
                
                % compute performance
                tp =length(find(labc_val==1 & class==1)); % TruePos
                tn =length(find(labc_val==0 & class==0)); % TrueNeg
                fp =length(find(labc_val==0 & class==1)); % FalsePos
                fn =length(find(labc_val==1 & class==0)); % FalseNeg
                
                if (tn+fp)==0
                    bac_c(c,m) =tp./(tp+fn);
                elseif (tp+fn)==0
                    bac_c(c,m) =tn./(tn+fp);
                else
                    bac_c(c,m) =((tp./(tp+fn))+(tn./(tn+fp)))./2;
                end
            catch
                bac_c(c,m)=0;
                
            end
            
        end
    end
    
    [~,idx]=max(mean(bac_c,2));
    C=Cvec(idx); % select the optimal C-parameter
    Ccv(cv)=C;
    %% (2) train and validate the SVM with the selected C-parameter
   
    valid1=s1(rp1(ntrain1+1:end),:); % take remaining trials for validation
    valid2=s2(rp2(ntrain2+1:end),:);
    
    validate=cat(1,valid1,valid2); % validation data
    
    try
        
        svmstruct=svmtrain(train,label,'kernel_function','linear','boxconstraint',C); % train
        class=svmclassify(svmstruct,validate); % validate
        
        % compute performance
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
    
    
end

bac=mean(bac_cv); % average across cv

end

