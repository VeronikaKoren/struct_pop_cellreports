%% spike-triggered population activity in the two conditions


close all
clear all
clc
format long

saveres=0;  								     % save result?
ba=1;
period=2;

namea={'V1','V4'};
namep={'target','test'};

start_vec=[200,500];
start=start_vec(period);                                                     % start of the time window
L=500; 

nbit=20;

iW=100;                                                                      % half width of the window
iWindex=-iW:iW;                                                              % time window of interest for stpa

%% load data

addpath('/home/veronika/synced/struct_result/input/')

loadname=['spike_train_',namea{ba},'_',namep{period},'.mat'];                  % load spike trains
load(loadname);
nbses=size(spiketrain,1);

spikes_time=cellfun(@(x) single(x(:,:,start:start+L-1)),spiketrain,'UniformOutput',false);

%% compute spike-triggered MUA

display(['spike-triggered MUA in ',namea{ba}, ' ', namep{period}])

                                                                  
smua_nm=[];
smua_m=[];

for sess = 1:nbses                                                                    % loop across layers
     
    s_sess=spikes_time(sess,:);                                               % select time window and get a matrix (J,N,K)
    J=cellfun(@(x) size(x,1),s_sess);                                                                                          % nb of trials
    N=size(s_sess{1},2);
    
    for c=1:2
        
        s_timing=s_sess{c};
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% smua raw
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        smua_raw=zeros(J(c),2*iW+1,N);
        
        for j=1:J(c)
            
            xall=squeeze(s_timing(j,:,:));
            
            for n=1:N
                xr=xall;
                xr(n,:)=[];                                        % remove the neuron n
                mua=mean(xr);
                o=xall(n,:);
                
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
            
            s_perm=s_timing(randperm(J(c)),:,:);
            smua_p=zeros(J(c),2*iW+1,N);
            for j=1:J(c)
                
                xp_all=squeeze(s_perm(j,:,:));
                
                for n=1:N
                    o=squeeze(s_timing(j,n,:));
                    
                    xp=xp_all;
                    xp(n,:)=[];                                        % remove the neuron n
                    muap=mean(xp);
                    
                    for t=iW+1:(L-1)-iW                   			%at least t=101
                        
                        if o(t-1)==1
                            smua_p(j,:,n)=smua_p(j,:,n)+muap(1,t-iW:t+iW);
                        end
                    end
                end
            end
            
            smua_it(it,:,:)=nanmean(smua_raw-smua_p);                       % average across trials
        end
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        smua=squeeze(mean(smua_it));                                    % average across iterations
        if c==1
            smua_nm=cat(2,smua_nm,smua);                                % concatenate neurons across sessions
        else
            smua_m=cat(2,smua_m,smua);
        end
        
    end
    
end

%%

peak_nm=smua_nm(iW+1,:);
peak_m=smua_m(iW+1,:);
R=corr(peak_nm',peak_m');
pval_sr=signrank(peak_nm',peak_m','tail','both');
disp(pval_sr)

%%
figure()
subplot(1,2,1)
hold on
plot(-iW:iW,mean(smua_nm,2),'b')
plot(-iW+10:iW+10, mean(smua_m,2),'r')
xlim([-iW,iW])
legend('non-match','match','location','South')
xlabel('lag (ms)')
ylabel('spike-triggered MUA')
box off

subplot(1,2,2)
plot(peak_nm,peak_m,'k.','markersize',6)
text(-0.1,0.3,['R = ' sprintf('%0.4f',R)])
lsline
axis([-0.15,0.4,-0.15,0.4])
xlabel('peak non-match')
ylabel('peak match')
box off
%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/coupling/2_cond/';
    filename=['smua_2c_',namea{ba},'_',namep{period}];
    save([address, filename],'smua_nm','smua_m')
end
%}
