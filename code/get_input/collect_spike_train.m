
close all
clear all
clc

saveres=1;                                                                          % save result?

ba=1;
period=2; 
beh=[2,3];

%%

start_vec=[200,500];                                                             % beginning of the time window for the target (200) and the test stimulus (500) 
start=start_vec(period);

ending={'_all','_lay'};
namea={'V1','V4'};
namep={'target','test'};
variables={'spikes_tar','spikes_test';'spikes_tarV4_lay','spikes_testV4_lay'};
                                                                     
display(['collect spike trains ',namea{ba},' ', namep{period}])

%%

addpath('/home/veronika/v1v4/data/')
dname=['/home/veronika/v1v4/data/',namea{ba},ending{ba},'/'];    
fname=dir([dname filesep '*.mat']);                                             % name of the data file                                                                                                                                                                                            
cvar=variables{ba,period};

%%                                                                         
spiketrain=[];

counter=0;
for sess = 1:length(fname)
    
    display(sess,'session')
    
    s=load([dname filesep fname(sess).name],cvar);                                                                                      % load data in a session
    N=size(s.(cvar){1,1},2)+size(s.(cvar){1,2},2)+size(s.(cvar){1,3},2); 
    
    if N<6
        continue
    else
        
        counter=counter+1;
        npair=(N^2-N)/2;
        
        s_beh=s.(cvar)(beh,:);
        
        s_catlay=cellfun(@(x,y,z) cat(2,x,y,z), s_beh(:,1), s_beh(:,2), s_beh(:,3), 'UniformOutput', false);
        %s_catbeh=cellfun(@(x,y) cat(1,x,y), s_catlay(1), s_catlay(2), 'UniformOutput', false);
        s_int=cellfun(@(x) int8(x), s_catlay', 'UniformOutput', false);
        spiketrain=cat(1,spiketrain,s_int);
    end    
  
end


%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/input/';
    filename=['spike_train_choice_',namea{ba},'_',namep{period}];
    save([address, filename], 'spiketrain')
   
end




