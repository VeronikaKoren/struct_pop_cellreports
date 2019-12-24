function [ r] = noise_correlation_sign_fun( input,w)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%%
                                                         

md=repmat(mean(input),size(input,1),1);                                      % z-score the spike counts
sd=repmat(std(input),size(input,1),1);
zscored=(input-md)./sd;

neg=find(w<0);
pos=find(w>0);
sc_neg=zscored(:,neg);
sc_pos=zscored(:,pos);

%% noise correlation of spike counts
% on regular input
npair=length(pos)*length(neg);
r=zeros(npair,1);
idx=0;
for i=1:length(pos)
    
    x=sc_pos(:,i);
    
    for j=1:length(neg)
        idx=idx+1;
        y=sc_neg(:,j);
        
        r(idx)=corr(x,y);
    end
end
%%
% with permuted order of trials
%{
r_perm=zeros(npair,nperm);
for p=1:nperm
    
    random_order=randperm(ntrial);
    idx=0;
    for i=1:length(pos) 
        x=sc_pos(random_order,i);
        
        for j=1:length(neg)
            idx=idx+1;
            y=sc_neg(:,j);
            
            r_perm(idx,p)=corr(x,y);
        end
    end
end
%}

end

