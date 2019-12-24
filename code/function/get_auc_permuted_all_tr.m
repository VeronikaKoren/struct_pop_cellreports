function [a_perm] = get_auc_permuted_all_tr( data1,data2, xvec,bw,nperm )

%% this function is similar to "get_auc_all_trials", but here, the area under ROC curve is computed with random permutation of class labels
% the two vectors of data are concatenated ("d_all") and 
% for each iteration, the indexes of the "d_all" are randomly permuted
% without repetition and split in two according to the number of samples of
% the original data samples

data1=data1(:);
data2=data2(:);

a_perm=zeros(1,nperm);

n1=length(data1);
n2=length(data2);

d_all=[data1;data2]; % concatenate data from the 2 distributions

for pp=1:nperm % loop for permutations
    rp=randperm(n1+n2); % randomly permute trial indexes 
    d1=ksdensity(d_all(rp(1:n1)),xvec,'bandwidth',bw); % take n1 trials for the probability density for conditions 1
    d2=ksdensity(d_all(rp(n1+1:end)),xvec,'bandwidth',bw); % take n2 trials for the probability density for conditions 2
    
    d1n=d1./sum(d1); % normalize
    d2n=d2./sum(d2);
    
    r1=cumsum([0,d1n]); % cumulative distribution function
    r2=cumsum([0,d2n]);
    
    a_perm(1,pp)=trapz(r2,r1); % area under the curve
    
end


end

