% compute ccg noise for all neurons in the session, distinguish conditions 
% cross-correlation of the noise (ccg_raw - ccg_trial_invariant)

close all
clear all
clc
format long

place=1;
saveres=0;                                                                          % save result?
showfig=1;

ba=2;
period=2;       

namea={'V1','V4'};
namep={'target','test'};  

K=500;                                                                       % number of time steps
start_vec=[200,500];                                                         % beginning of the time window for the target (200) and the test stimulus (500) 
start=start_vec(period);

nshuffle=20;                                                                  % number of trial order permutations for computing the trial invariant ccg (to be subtracted from the raw cross-correlation function)

%%
display(['ccg all neurons 2 conditions ',namea{ba},' ', namep{period}])

addpath('/home/veronika/synced/struct_result/input/');
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname2=['spike_train_',namea{ba},'_',namep{period}];
load(loadname2);
strain=cellfun(@(x) single(x),spiketrain, 'UniformOutput', false);                                                                         

%% compute ccg from all trials

nbses=size(strain,1);
ccg=cell(nbses,2);                                                                             

tic
for sess = 1:nbses
    for c=1:2
        spike_train=strain{sess,c}(:,:,start:start+K-1);
        ccg{sess,c}=ccg_fun(spike_train,nshuffle);    
    end
end
toc

%%
ccg_nm=cell2mat(ccg(:,1));
ccg_m=cell2mat(ccg(:,2));
%% show figure

if showfig==1
    figure()
    hold on
    plot(mean(ccg_nm))
    plot(mean(ccg_m))
end

%% save results

if saveres==1
    
    address='/home/veronika/synced/struct_pop/result/pairwise/ccg_2c/';
    filename=['ccg2c_',namea{ba},'_',namep{period}];
    save([address, filename], 'ccg_nm','ccg_m')
end




