%% spike-triggered population activity for every neuron

close all
clear all
clc
format long

saveres=1;                                                                  % save result?
showfig=1;
place=1;

ba=1;
period=2;
window=3;                                   

nbit=20;                                                                    % number of iteration for trial invariant smua

                                                                                          
start_vec=[500,500,750] - 300*(period==1);                                    % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);
iW=50;                                                                         % maximal lag

display([start,start+K],'window')
 
%%

namea={'V1','V4'};
namep={'target','test'};
namew={'','first_half','second_half'};

%% 
display(['STPA all ',namea{ba}, ' ', namew{window}])

addpath '/home/veronika/synced/struct_result/input/'

if place==1
    addpath '/home/veronika/Dropbox/struct_pop/code/function/'
else
    addpath '/home/veronika/struct_pop/code/function/'
end

%% load spike trains

loadname=['spike_train_',namea{ba},'_',namep{period}];                          
load(loadname)

% use one condition
%strain_all=cellfun(@(x,y) single(x(:,:,start:start+K-1)), spiketrain(:,cond),'UniformOutput',false);

% use both conditions
strain_all=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))), spiketrain(:,1),spiketrain(:,2),'UniformOutput',false);
nbses=length(strain_all);

%% compute spike-triggered population activity

stpa_all=cell(nbses,1);

parfor sess = 1:nbses                                                              
    
    s_train=strain_all{sess};
    [smua] = smua_fun(s_train,nbit,iW);
    stpa_all{sess}=smua';
    
end

%% get the stpa at zero time lag

peak=cellfun(@(x) x(:,iW),stpa_all,'UniformOutput', false);


%% plot
   
if showfig==1
    
    stpa=cell2mat(stpa_all);
    peaks_vec=cell2mat(peak);
    
    figure('name',['STpop ',namea{ba},namep{period}])
    for n=1:16
        i=n+16;
        subplot(4,4,n)
        plot(-iW+1:iW+1,stpa(i,:),'k')
        axis([-iW,iW,-0.01,0.06])
        box off
    end
    
    figure('name','peaks')
    ksdensity(peaks_vec)
end


%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/coupling/1_cond/';
    filename=['stpa_1c_',namea{ba},namep{period},'_',namew{window}];
    save([address, filename],'stpa_all','peak','iW')
end
