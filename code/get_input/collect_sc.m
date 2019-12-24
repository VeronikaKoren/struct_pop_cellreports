%% collect spike counts in column for each recording session
% save for each session

close all
clear all
clc
format long

saveres=1;                                                                  % save result?
ba=2;
beh=[1,3];                                                                  % correct NM and correct M


namea={'V1','V4'};
namep={'target','test'};
ending={'_all','_lay'};
variables={'spikes_tar','spikes_test';'spikes_tarV4_lay','spikes_testV4_lay'};

dt=1/1000;
nstep=499;                                                                          % number of time steps
start=[200,500];                                                                    % beginning of the time window for the target (200) and the test stimulus (500) 

display(['spike counts in column of ',namea{ba}])

%% compute spike counts
    
dname=['/home/veronika/v1v4/data/',namea{ba},ending{ba},'/'];
fname=dir([dname filesep '*.mat']);                                                   
nbses=length(fname);                                                                   % number of sessions

cvar_tar=variables{ba,1};
cvar_test=variables{ba,2};

sc_tar=[];
sc_test=[];

counter=0;
for sess = 1:nbses                                                                                      % across sessions
    
    s=load([dname filesep fname(sess).name],cvar_tar,cvar_test);                                        % load data in a session
    N=size(s.(cvar_tar){1,1},2)+size(s.(cvar_tar){1,2},2)+size(s.(cvar_tar){1,3},2);                     % number of cells in a session
    
    if N<6
        continue
    else
        counter=counter+1;
        
        sctar=cell(length(beh),1);
        sctest=cell(length(beh),1);
        
        for c=1:length(beh)
            
            star=s.(cvar_tar)(beh(c),:);                                                                    % use particular condition; target
            stest=s.(cvar_test)(beh(c),:);                                                                  % test
            
            cat_tar=cellfun(@(x,y,z) cat(2,x,y,z),star(1),star(2),star(3),'UniformOutput',false);           % concatenate layers
            cat_test=cellfun(@(x,y,z) cat(2,x,y,z),stest(1),stest(2),stest(3),'UniformOutput',false);
            
            sctar(c)=cellfun(@(x) mean(x(:,:,start(1):start(1)+nstep),3)./dt, cat_tar,'UniformOutput',false);   % compute the firing rate in the desired time window
            sctest(c)=cellfun(@(x) mean(x(:,:,start(2):start(2)+nstep),3)./dt, cat_test,'UniformOutput',false);
            
        end
        
        sc_tar=cat(2,sc_tar,sctar);                                                                         % collect across sessions
        sc_test=cat(2,sc_test,sctest);
        
    end
    
end    

%% save results

if saveres==1
    address='/home/veronika/struct_pop/result/spike_count/';
    filename=['sc_',namea{ba}];
    save([address, filename],'sc_tar','sc_test')
end
