function [ r] = noise_correlation_sc_fun( sc)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%%

ncell=size(sc,2);                                                          % z-score the spike counts

%%
npair=(ncell^2-ncell)/2;
md=repmat(mean(sc),size(sc,1),1);
sd=repmat(std(sc),size(sc,1),1);
zscored=(sc-md)./sd;

% correlation of z-scored spike counts
% regular

r=zeros(npair,1);
idx=0;
for i=1:ncell-1
    
    x=zscored(:,i);
    
    for j=i+1:ncell
        idx=idx+1;
        y=zscored(:,j);
        
        r(idx)=corr(x,y);
    end
end
%%
% with permuted order of trials
%{
if nperm>0
    r_perm=zeros(npair,nperm);
    for p=1:nperm
        
        random_order=randperm(ntrial);
        
        idx=0;
        for i=1:ncell-1
            
            x=zscored(random_order,i);
            
            for j=i+1:ncell
                idx=idx+1;
                y=zscored(:,j);
                r_perm(idx,p)=corr(x,y);
            end
        end
    end
else
    r_perm=NaN
end

%%
rp=mean(r_perm,2);

%%

figure()
plot(r)
hold on
plot(rp)
plot(r-rp)
legend('z-scored','permuted trial order','zsored-permuted')
%%
%}

end

