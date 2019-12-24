% compute noise correlation of spike counts for pairs of neurons in
% the session
% concatenate results across sessions
% rsc is computed from a vector of z-scored spike counts 
% rsc_perm is computed with one of the two vectors is permuted across trials
% rsc_noise=rsc_raw - rsc_perm

close all
clear all
clc 
format long

saveres=0;
showfig=1;

ba=1;
period=2;

nperm=10;
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

strain=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);   % concatenate trials from the two conditions
sc_all=cellfun(@(x) squeeze(sum(x,3)) ,strain, 'UniformOutput',false);
nbses=size(strain,1);

disp(['computing rsc_noise 1c in ', namea{ba}, ' ', namep{period}])
%%

rsc=[]; 

for ss=1:nbses                                                                  % recording sessions
    
    sc=sc_all{ss};
    [ r] = noise_correlation_sc_fun( sc);
    rsc=cat(1,rsc,r);
    
end
    

%%

if showfig==1
    [x, vec]=ksdensity(rsc);
    
    figure()
    plot(vec,x./sum(x))
    title('distribution of r_{sc} noise')
    xlabel('r_{sc} noise')
    ylabel('probability dstribution')
    
end

%% save result

if saveres==1
    address='/home/veronika/synced/struct_result/pairwise/rsc/rsc_1c/';
    filename=['rsc_1c_',namea{ba},'_',namep{period}];
    save([address,filename],'rsc', 'rsc_perm')
end
