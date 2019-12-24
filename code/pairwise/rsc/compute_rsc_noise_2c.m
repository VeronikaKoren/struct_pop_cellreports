% compute noise correlation of spike counts for pairs of neurons in
% the column for each condition
% concatenate results across sessions


close all
clear all
clc 
format long

saveres=0;

ba=1;
period=2;

nperm=1;
K=500;                                                                          % number of time steps
start_vec=[200,500];                                                             % beginning of the time window for the target (200) and the test stimulus (500) 
start=start_vec(period);

%% load data

namea={'V1','V4'};
namep={'tar','test'};

addpath('/home/veronika/Dropbox/struct_pop/code/function/')
addpath('/home/veronika/synced/struct_result/input/')

loadname=['spike_train_',namea{ba},'_',namep{period}];
load(loadname);

strain=cellfun(@(x) single(x(:,:,start:start+K-1)),spiketrain, 'UniformOutput', false);   % use the desired time window
sc_all=cellfun(@(x) squeeze(sum(x,3)) ,strain, 'UniformOutput',false);

nbses=size(sc_all,2);
disp(['computing rsc_noise 2c in ', namea{ba}, ' ', namep{period}])
%%

rsc=[]; 

for c=1:2                                                                         % conditions
    
    r_cat=[];
    
    for ss=1:nbses                                                                  % recording sessions
        
        sc=sc_all{ss,c};
        r = noise_correlation_sc_fun( sc);
        r_cat=cat(1,r_cat,r);
        
    end
    
    rsc=cat(2,rsc,r_cat);
   
end

%%

figure()
ecdf(rsc(:,1))
hold on
ecdf(rsc(:,2))
title('r_{sc}')
legend('non-match','match','Location','best')
[h,p]=ttest2(rsc(:,1),rsc(:,2));

%% save result

if saveres==1
    address='/home/veronika/synced/struct_result/rsc/rsc_2c/';
    filename=['rsc_2c',namea{ba},'_',namep{period}];
    save([address,filename],'rsc')
end
