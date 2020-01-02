%% spike-triggered population activty within the group of informative and less informative neurons

close all
clear all
clc
format long

saveres=0;                                                                  % save result?
showfig=1;
place=1;

ba=2;
period=2;
window=1;                                   

nbit=20;                                                                    % number of iteration for trial invariant smua
nperm=1000;
                                                                                          
start_vec=[500,500,750] - 300*(period==1);                                    % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);
iW=50;                                                                         % maximal lag

display([start,start+K],'window')
 
%%

namea={'V1','V4'};
namep={'target','test'};
namew={'','first_half_','second_half_'};

%% 
display(['spike-triggered pop info ',namea{ba}, ' ', namew{window}])

addpath '/home/veronika/synced/struct_result/input/'
addpath '/home/veronika/synced/struct_result/weights/tag/'

if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')
else
    addpath('/home/veronika/struct_pop/code/function/')
end

%% load spike trains

loadname=['spike_train_',namea{ba},'_',namep{period}];                          
load(loadname)

% use one condition
%strain_all=cellfun(@(x,y) single(x(:,:,start:start+K-1)), spiketrain(:,cond),'UniformOutput',false);

% use both conditions
strain_all=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))), spiketrain(:,1),spiketrain(:,2),'UniformOutput',false);
nbses=length(strain_all);


loadname3=['tag_info_', namea{ba},namep{period},'_',namew{window}];         % load tag informative neurons whole window
load(loadname3)

%% compute spike-triggered population activity

smua_i=cell(nbses,1);
smua_noi=cell(nbses,1);
smua_ip=cell(nbses,1);
smua_noip=cell(nbses,1);

parfor sess = 1:nbses                                                              
    
    strain_sess=strain_all{sess};
    N=size(strain_sess,2);
    
    %%%%%%%%%%%%%%%%% regular %%%%%%%%%%%%%%%
    
    %% NOT Info (use noinf neurons)
     
    idx_noi=find(tag_info{sess}==0);
    n1=length(idx_noi);
    if n1>1
        s_train=strain_sess(:,idx_noi,:);
        [smua] = smua_fun(s_train,nbit,iW);
        smua_noi{sess}=double(smua');
    end
    %% INFO (use info neurons)
    
    idx_i=find(tag_info{sess});
    n2=length(idx_i);
    if n2>1
        s_train=strain_sess(:,idx_i,:);
        [smua] = smua_fun(s_train,nbit,iW);    
        smua_i{sess}=double(smua');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% with random neuron idx
    
    p1=zeros(n1,nperm,2*iW+1);
    p2=zeros(n2,nperm,2*iW+1);
    
    for perm=1:nperm
        
        idx_random=randperm(N);                                                % randomize the order
        if n1>1
            s_train=strain_sess(:,idx_random(1:n1),:);                           % choose 3 neurons
            [smua] = smua_fun(s_train,nbit,iW);
            p1(:,perm,:)=double(smua');
        end
        
        if n2>1
            s_train=strain_sess(:,idx_random(n1+1:end),:);                   % choose 3 neurons
            [smua] = smua_fun(s_train,nbit,iW);
            p2(:,perm,:)=double(smua');
        end
    end
    
    smua_noip{sess}=p1;
    smua_ip{sess}=p2;
    
end

%% concatenate across sessions

smua_i=cell2mat(smua_i);
smua_noi=cell2mat(smua_noi);
smua_noip=cell2mat(smua_noip);
smua_ip=cell2mat(smua_ip);

%% permutation test coupling synchrony

d=mean(smua_i(:,iW))-mean(smua_noi(:,iW));
d0=mean(smua_ip(:,:,iW))-mean(smua_noip(:,:,iW));

pval=sum(d<d0)./nperm;
display(pval);

%% plot
   
if showfig==1
    
    orange=[1,0.3,0.05];
    gray=[0.2,0.2,0.2];
    
    %maxy=max([mean(smua_noi(:,iW)), mean(smua_i(:,iW))]);
    
    [~,idx]=max(smua_i(:,iW));
    maxy=smua_i(idx,iW);
    
    figure('name',['STpop ',namea{ba},namep{period}])
    subplot(1,2,1)
    hold on
    
    plot(-iW:iW,smua_i(idx,:),'color',orange,'linewidth',2)
    plot(-iW:iW, smua_noi(idx,:),'color',gray,'linewidth',2)
    
    xlim([-iW,iW])
    legend('informative','not informative','location','NorthEast')
    xlabel('lag (ms)')
    ylabel('spike-triggered population activity')
    box off
    ylim([-0.02,maxy+maxy*0.5])
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [f,x1]=ecdf(smua_i(:,iW));
    [g,x2]=ecdf(smua_noi(:,iW));
    
    subplot(2,2,2)
    plot(x1,f,'color',orange)
    hold on
    plot(x2,g,'color',gray)
    hold off
    grid on
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    y=[mean(smua_i(:,iW)), mean(smua_noi(:,iW))];
    maxy=max(y);
    
    subplot(2,2,4)
    hold on
    bb=bar(y,'FaceColor','flat');
    if pval<0.05
        plot(1.5,maxy+0.2*maxy,'k*')
    end
    hold off
    
    bb.CData(1,:)=orange;
    bb.CData(2,:)=gray;
    ylabel('peak height')
    set(gca,'XTickLabel',[])
    box off
    
    
end

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/coupling/info/';
    filename=['stpa_info_',namea{ba},namep{period},'_',namew{window}];
    save([address, filename],'smua_i','smua_noi','smua_noip','smua_ip','pval','iW')
end
