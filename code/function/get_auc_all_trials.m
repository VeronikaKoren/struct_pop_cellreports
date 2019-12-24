function [ auc,bw,g1m,g2m ] = get_auc_all_trials( data1,data2, xvec )

%% PURPOSE: computes area under the ROC curve  

%% DESCRIPTION: 

% input: "data 1" and "data 2" are data vectors with input statistics; two vectors of arbitraty length, they can have different length; here we use spike counts of a single neuron in conditions 1 and 2  
% input: xvec is the support for the probability distribution
% output: auc is the area under the ROC curve
% output: bw is the bandwidth that was used for computing the probability distributions 
%


data1=data1(:);
data2=data2(:);

% estimate average bandwidth
 
[~,~,u1]=ksdensity(data1(:),xvec);
[~,~,u2]=ksdensity(data2(:),xvec);


bw=mean([u1,u2]);%bandwidth for this neuron

%% get probability distribution

g1=ksdensity(data1,xvec,'bandwidth',bw);
g2=ksdensity(data2,xvec,'bandwidth',bw);
    
g1m=g1./sum(g1); % normalize distribution
g2m=g2./sum(g2);

%% compute the auc score


r1=cumsum([0,g1m]); % empirical cumulative distribution function
r2=cumsum([0,g2m]);

auc=trapz(r2,r1); % area under the ROC curve


end

