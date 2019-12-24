function [ bac,bacp, C_cv ] = svm_mc_tv_fun(training_data,validation_data,nfold,nperm,Cvec)

%% linear SVM with monte-carlo cross-validation
% procedure: (1) choose the optimal C-parameter, (2) train and test the model, (3) compute the model with permuted class labels %%

%% inputs: 
% "training_data" is a cell of the form (number of cross-validations x number of conditions=2), in each cell there is a matrix of the form (nb.of trials for training x number of neurons)
% "validation_data" is, similarly, a cell of the form (number of cross-validations x number of conditions=2), but in each cell there is a matrix of the form (nb.of trials for validaion x number of neurons)
% "nfold" is the number of folds for the selection fo the regularization parameter
% "nperm" is the number of permutations of class labels; 
% "Cvec" is the vector of tested regularization parmeters

%% outputs: 
% "bac" is the balanced accuracy, averaged across cross-validations
% "bacp" is the distributions of balanced accuracies with permuted class
% labels, averaged across cross-validations
% "C_cv" are chosen regularization parameters in cross-validation sets


ntrain1=size(training_data{1,1},1);         % number of samples condition 1
ntrain2=size(training_data{1,2},1);         % condition 2

n1=ntrain1 + size(validation_data{1,1},1);  % total number of trials condition 1
n2=ntrain2 + size(validation_data{1,2},1);  % condition 2

label=cat(1,zeros(ntrain1,1),ones(ntrain2,1));           % training labels
label_val=cat(1,zeros(n1-ntrain1,1),ones(n2-ntrain2,1)); % validation labels
N=floor(length(label)/nfold);                            % number of samples in n-fold cross-validation
ncv=size(training_data,1);                               % number of cross-validations for splits of the data into training and validations set

bac_cv=zeros(ncv,1);
bacp_cv=zeros(ncv,nperm);
C_cv=zeros(ncv,1);

for cv=1:ncv % cross-validations
      
    % training and validation data in one cross-validation set
    train=cat(1,training_data{cv,1},training_data{cv,2});
    validate=cat(1,validation_data{cv,1},validation_data{cv,2});

    %%% (1) find the optimal C-parameter
    
    new_order=randperm(size(train,1));
    s_new=train(new_order,:);   % permute order for 10-fold cv
    label_new=label(new_order);
    
    bac_c=zeros(length(Cvec),nfold);
    for c=1:length(Cvec)        % range of C-parameters
        
        for m=1:nfold           % 10-fold cross-validation
            
            xc_train=[s_new(1:(m-1)*N,:);s_new(m*N + 1 : end,:)];       % data for training
            labc_train=[label_new(1:(m-1)*N);label_new(m * N + 1:end)]; % label training
            
            xc_val=s_new(1+(m-1)*N:m*N,:);
            labc_val=label_new(1+(m-1)*N:m*N);
            
            try
                
                svmstruct=svmtrain(xc_train,labc_train,'kernel_function','linear','boxconstraint',Cvec(c));% train the svm
                class=svmclassify(svmstruct,xc_val); % validate
                
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
    
    [~,idx]=max(mean(bac_c,2)); % average across 10-fold cv and take the max across the tested C-parameters
    C=Cvec(idx); % choose the regularization parameter with highest accuracy
    C_cv(cv)=C;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% (2) train and test the SVM with selected C-parameter
    try
        
        svmstruct=svmtrain(train,label,'kernel_function','linear','boxconstraint',C);
        class=svmclassify(svmstruct,validate);
        
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
    
    %% (3) train and test the same data with permutation of labels
    for p=1:nperm
        labelp=label(randperm(length(label))); % random permutation of  training labels
        try
            
            svmstruct=svmtrain(train,labelp,'kernel_function','linear','boxconstraint',C);
            class=svmclassify(svmstruct,validate);
            
            tp =length(find(label_val==1 & class==1)); % TruePos
            tn =length(find(label_val==0 & class==0)); % TrueNeg
            fp =length(find(label_val==0 & class==1)); % FalsePos
            fn =length(find(label_val==1 & class==0)); % FalseNeg
            
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

% average across cv
bac=mean(bac_cv);
bacp=mean(bacp_cv);

end

