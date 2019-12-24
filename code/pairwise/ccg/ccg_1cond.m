% compute rccg noise for all neurons in the session using trials from both
% conditions
% cross-norrelation (ccg_raw - ccg_trial_invariant)

close all
clear all
clc
%format long

place=1;
saveres=0;                                                                          % save result?
showfig=1;

ba=2;
period=2;       

namea={'V1','V4'};
namep={'target','test'};  

K=500;                                                                          % number of time steps
start_vec=[200,500];                                                             % beginning of the time window for the target (200) and the test stimulus (500) 
start=start_vec(period);

nshuffle=2;                                                                  % number of trial order permutations for computing the trial invariant ccg (to be subtracted from the cross-correlation function)

%%

addpath('/home/veronika/synced/struct_result/input/');
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

loadname2=['spike_train_',namea{ba},'_',namep{period}];
load(loadname2);
strain=cellfun(@(x,y) single(cat(1,x,y)),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);                                                                         

%% compute ccg from all trials

display(['ccg all neurons 1 condition ',namea{ba},' ', namep{period}])

nbses=size(strain,1);
ccg=cell(nbses,1);                                                                             

tic
for sess = 1%:nbses
    
    spike_train=strain{sess}(:,:,start:start+K-1);
    ccg{sess}=ccg_fun(spike_train,nshuffle);    
        
end
toc

ccg1c=cell2mat(ccg);

%% show figure

if showfig==1
    figure()
    hold on
    plot(mean(ccg1c))
end

%% save results

if saveres==1
    
    address='/home/veronika/synced/struct_result/pairwise/ccg_1c/';
    filename=['ccg1c_',namea{ba},'_',namep{period}];
    save([address, filename], 'ccg1c')
end



