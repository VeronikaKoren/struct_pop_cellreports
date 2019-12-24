function [weight] = compute_svmw_fun(count,nfold,Cvec)

format long
%%%%%%%%%%%%%%%%% computes linear svm on spike counts 
% details:
% binary classification of high-dimensional activity profiles of simultaneously active neurons; input dimensionality: N-by-ntrial
% all trials are used
% standardized data
% estimates the best C-parameter with 10-fold cross-validation
% computes feature weights from support vectors

%% standardize

ntr=cellfun(@(x) size(x,1),count); % nb of trials in each condition
nfeatures=size(count{1},2);

mat=cat(1,count{1},count{2});
stds=repmat(std(mat),size(mat,1),1);
%maxes=repmat(max(mat),size(mat,1),1);
means=repmat(mean(mat),size(mat,1),1); % regularize spike counts by subtracting the mean and dividing by std, for each neuron

matn=(mat-means)./stds;

%%
label=cat(1,ones(ntr(1),1).*(-1),ones(ntr(2),1));
rp=randperm(sum(ntr));
matnp=matn(rp,:);
label=label(rp);

Ntr=floor(size(matnp,1)/nfold);         % nb trials in a split
bac_c=zeros(length(Cvec),nfold);

%% select C-parameter

for j=1:length(Cvec)                    % cross-validation for splits into training are test data
    C=Cvec(j);
    
    for m=1:nfold                       % n-fold cross-validation for splitting again the training data into training and validation set
        
        xtest=matnp(1+(m-1)*Ntr:m*Ntr,:);                                   % data for testing
        xtrain=[matnp(1:(m-1)*Ntr,:);matnp(m*Ntr+1:end,:)];                 % data for training
        labc_train=[label(1:(m-1)*Ntr);label(m*Ntr+1:end)];                 % label training
        labc_test=label(1+(m-1)*Ntr:m*Ntr);                                 % label testing
        
        try
            
            svm=svmtrain(xtrain,labc_train','kernel_function','linear','boxconstraint',C, 'autoscale',false); % train linear svm
            class=svmclassify(svm,xtest); % classify the validation data
            
            tp =length(find(labc_test==1 & class==1)); % TruePos
            tn =length(find(labc_test==-1 & class==-1)); % TrueNeg
            fp =length(find(labc_test==-1 & class==1)); % FalsePos
            fn =length(find(labc_test==1 & class==-1)); % FalseNeg
            
            % balanced accuracy
            if tp==0
                bac_c(j,m)=tn./(tn+fp);
            elseif tn==0
                bac_c(j,m)=tp./(tp+fn);
            else
                bac_c(j,m) =((tp./(tp+fn))+(tn./(tn+fp)))./2;
            end
        catch
            bac_c(j,m)=0;
            
        end
    end
    
end

[~,idx]=max(mean(bac_c,2));
C=Cvec(idx);

%% train the classifier with selected C-parameter & Extract feature weights.
try
    svm=svmtrain(matnp,label,'kernel_function','linear','boxconstraint',C, 'autoscale', false);
    
    %{
    % performance on training data
    class=svmclassify(svm,matnp);
    tp =length(find(label==1 & class==1)); % TruePos
    tn =length(find(label==-1 & class==-1)); % TrueNeg
    fp =length(find(label==-1 & class==1)); % FalsePos
    fn =length(find(label==1 & class==-1)); % FalseNeg
    if tp==0
        bac_train=tn./(tn+fp);
    elseif tn==0
        bac_train=tp./(tp+fn);
    else
        bac_train=((tp./(tp+fn))+(tn./(tn+fp)))./2;   % balanced accuracy
    end
    %}
    
    svt=svm.SupportVectorIndices;                                                       % indices of used trials
    y=label(svt);                                                                       % label of used trials
    
    wi=zeros(length(svm.Alpha),nfeatures);                                             % svm.SupportVectors~(n_used_trials,n_neurons)
    for k=1:length(svm.Alpha)                                                          % svm.Alpha~ Lagrange multiplier
        wi(k,:)=svm.Alpha(k,1)*y(k,1)*svm.SupportVectors(k,:);                         % length(svm.Alpha) ~ number of support vectors
    end
    
    w=sum(wi,1);                                                                       % feature weights of the SVM 
    weight=w./sqrt(sum(w.^2));
    
catch
    weight=zeros(1,nfeatures);
    disp('No convergence!')
    
end
