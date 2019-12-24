%% spike-triggered MUA in one condition
% save results for each session

close all
clear all
clc
format long

saveres=0;  % save result?
ba=2;
period=2;

namea={'V1','V4'};
namep={'target','test'};

start_vec=[200,500];
start=start_vec(period);                                                      % start of the time window
L=500; 

nbit=3;

%% load data

addpath('/home/veronika/synced/struct_result/input/')

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

spikes_time=cellfun(@(x,y) cat(1,x(:,:,start:start+L-1),y(:,:,start:start+L-1)),spiketrain(:,1),spiketrain(:,2),'UniformOutput',false)

display(['spike-triggered MUA 1c in column of ',namea{ba}, ' ', namep{period}])
%
%% compute

iW=100;                                                                                 % half width of the window
iWindex=-iW:iW;                                                                         % time window of interest for s-MUA

smua_cat=[];

for sess = 1:nbses                                                                                                  % loop across sessions
    
    s_timing=single(spikes_time{sess});                                               % select time window and get a matrix (J,N,K)
    J=size(s_timing,1);                                                                                          % nb of trials
    N=size(s_timing,2);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% smua raw
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    smua_raw=zeros(J,2*iW+1,N);
    
    for j=1:J
        
        xall=squeeze(s_timing(j,:,:));                                                                          %  (N,K)
        
        for n=1:N
            xr=xall;
            xr(n,:)=[];                                                                                         % remove the neuron n
            mua=mean(xr);                                                                                       % population activity
            o=xall(n,:);                                                                                        % spike of the neuron n
            
            for t=iW+1:(L-1)-iW                   %at least t=101
                
                if o(t-1)==1
                    smua_raw(j,:,n)=smua_raw(j,:,n)+mua(1,t-iW:t+iW);
                end
            end
        end
    end
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% smua perm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%
    
    smua_it=zeros(nbit,2*iW+1,N);
    for it=1:nbit
        
        s_perm=s_timing(randperm(J),:,:);                                   % permuted order of trials
        smua_p=zeros(J,2*iW+1,N);
        for j=1:J
            
            xp_all=squeeze(s_perm(j,:,:));
            
            for n=1:N
                o=squeeze(s_timing(j,n,:));
                
                xp=xp_all;
                xp(n,:)=[];                                                 % remove the neuron n
                muap=mean(xp);
                
                for t=iW+1:(L-1)-iW                                         %at least t=101
                    
                    if o(t-1)==1
                        smua_p(j,:,n)=smua_p(j,:,n)+muap(1,t-iW:t+iW);
                    end
                end
            end
        end
        
        smua_it(it,:,:)=nanmean(smua_raw-smua_p);                           % average across trials
    end
    
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    smua=squeeze(mean(smua_it));                                    % average across iterations
    smua_cat=cat(2,smua_cat,smua);
    
    
    
end

%%

peaks=smua_cat(iW+1,:);
[f,vec]=ksdensity(peaks);
f_norm=f./sum(f);

%%

figure()
subplot(1,2,1)
hold on
plot(-iW:iW,mean(smua_cat,2),'k')

xlim([-iW,iW])
xlabel('lag (ms)')
ylabel('spike-triggered MUA')
box off

subplot(1,2,2)
plot(vec,f_norm,'color','k')
xlabel('peak of smua')
ylabel('probability distribution')
box off

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/coupling/1_cond/';
    filename=['smua_1c_',namea{ba},'_',namep{period}];
    save([address, filename],'smua_cat', 'iW')
end
