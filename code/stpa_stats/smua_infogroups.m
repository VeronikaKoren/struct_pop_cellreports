%% spike-triggered MUA across informative and uninformative neurons


close all
clear all
clc
format long

place=1;
saveres=0;  % save result?
showfig=1;

ba=1;
period=2;

namea={'V1','V4'};
namep={'target','test'};

start_vec=[200,500];
start=start_vec(period);                                                     % start of the time window
L=500;

nbit=10;

%% add path

addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

%% load spiking data

loadname=['spike_train_',namea{ba},'_',namep{period}];                               % load spike trains
load(loadname)
strain_all=cellfun(@(x,y) single(cat(1,x(:,:,start:start+L-1),y(:,:,start:start+L-1))), spiketrain(:,1),spiketrain(:,2),'UniformOutput',false);

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                                 % load weights of the SVM
load(loadname2)
nbses=length(strain_all);

display(['spike-triggered MUA info ',namea{ba}, ' ', namep{period}])

%% get weights

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                       % load w_svm
load(loadname2)

%% compute

iW=100;                                                                           % half width of the window
iWindex=-iW:iW;                                                                   % time window of interest for s-MUA

smua_no2inf=[];
smua_inf2noinf=[];

for sess = 1:nbses                                                                    % loop across layers
    
    w=abs(weight_all{sess});
    [val,idx]=sort(w);
    N=length(w);
    
    strain_sess=strain_all{sess};
    J=size(strain_sess,1);
    
    for su=1:2
        
        if su==1
            idx_pop=idx(1:3);                                            % use noninformative for the population activity
            idx_s=idx(end-2:end);                                        % use informative for single neurons
        else
            idx_pop=idx(end-2:end);                                      % use informative for pop
            idx_s=idx(1:3);
        end
        
        s_pop=strain_sess(:,idx_pop,:);
        s_single=strain_sess(:,idx_s,:);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% smua raw
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        smua_raw=zeros(J,2*iW+1,3);
        for j=1:J
            mua=squeeze(mean(s_pop(j,:,:)))';
            for n=1:3
                
                o=squeeze(s_single(j,n,:));
                
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
        
        smua_it=zeros(nbit,2*iW+1,3);
        
        for it=1:nbit
            
            s_perm=s_pop(randperm(J),:,:);                                          % permute the trial order
            smua_p=zeros(J,2*iW+1,3);
            
            for j=1:J
                
                muap=squeeze(mean(s_perm(j,:,:)))';
                
                for n=1:3
                    o=squeeze(s_single(j,n,:));
                    
                    
                    for t=iW+1:(L-1)-iW                   %at least t=101
                        
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
        if su==1
            smua_no2inf=cat(2,smua_no2inf,smua);                                % concatenate neurons across sessions
        else
            smua_inf2noinf=cat(2,smua_inf2noinf,smua);
        end
        
    end
    
    
end

%%

delta=10;
if showfig==1
    
    r_noinf=mean(smua_no2inf(iW-delta:iW+delta,:));
    r_inf=mean(smua_inf2noinf(iW-delta:iW+delta,:));
   
    pval_sr=signrank(r_noinf',r_inf','tail','both');
    disp(pval_sr)
    
    maxy=max([nanmean(smua_no2inf(iW,:)), nanmean(smua_inf2noinf(iW,:))]);
    
    figure()
    subplot(1,2,1)
    hold on
    plot(-iW:iW,nanmean(smua_no2inf,2),'b')
    plot(-iW+10:iW+10, nanmean(smua_inf2noinf,2),'r')
    xlim([-iW,iW])
    legend('not info to info','info to not info','location','NorthEast')
    xlabel('lag (ms)')
    ylabel('spike-triggered population activity')
    box off
    ylim([-0.05,maxy+maxy*0.4])
    
    subplot(1,2,2)
    bb=bar([nanmean(r_noinf),nanmean(r_inf)],'FaceColor','flat');
    
    bb.CData(1,:) =[0,0,1];
    bb.CData(2,:) =[1,0,0];
    ylabel('coupling coefficient')
    set(gca,'XTickLabel',{'not info. to info.','info. to not info.'})
    xtickangle(45)
    box off
    
end
%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/coupling/info/';
    filename=['smua_infogroups_',namea{ba},'_',namep{period}];
    save([address, filename],'smua_no2inf','smua_inf2noinf')
end
%}