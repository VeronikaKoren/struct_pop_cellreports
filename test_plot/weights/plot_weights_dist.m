%% plot auc scores of single neurons in target and test 
% for V1 and V4

clear all
close all
format long

savefig=1;
period=1;
type=2;                                                             % 1 for AUC, 2 for SVM

namea={'V1','V4'};
namep={'target','test'};
namet={'AUC','SVM'};
longname={'AUROC','Weight linear SVM'};

% figure settings
savefile='/home/veronika/Dropbox/struct_pop/figure/weights/';
figname=['weights_',namet{type},'_',namep{period}];

pos_vec=[0,0,14,9];
fs=11;
ms=5;
lw=1.2;
lwa=1;


gray=[0.7,0.7,0.7];
blue=[0,0.48,0.74];
red=[0.85,0.32,0.4];

bv=[0.5,0]; % baseline

%% load results

addpath('/home/veronika/synced/struct_result/input/')

if type==1
    addpath('/home/veronika/synced/struct_result/classification/auc_regular/')
else
    addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
    addpath('/home/veronika/synced/struct_result/weights/weights_permuted/')
end

w=cell(2,1);        % {area} (Ntot);
wp=cell(2,1);       % {area} (Ntot,nperm);

for ba=1:2
    if type==1
        loadname=['auc_',namea{ba},namep{period},'.mat'];
        load(loadname);
        
        w{ba}=cell2mat(auc);
        wp{ba}=cell2mat(auc_perm);
    else
        loadname=['svmw_',namea{ba},namep{period},'.mat'];
        load(loadname);
        w{ba}=cell2mat(cellfun(@(x) single(permute(x,[2,1])),weight_all,'UniformOutput',false));
        
        loadname2=['svmw_perm_',namea{ba},namep{period},'.mat'];                                          
        load(loadname2)
        wp{ba}=cell2mat(weight_perm_all);
        
    end
    
end

nperm=size(wp{1,1},2);

%% get nb of neurons in sessions

ncell_sess=cell(2,1);
for ba=1:2
    loadname3=['spike_train_',namea{ba},'_',namep{period},'.mat'];
    load(loadname3)
    ncell_sess{ba}=cellfun(@(x) size(x,2),spiketrain(:,2));
end

%% 95 percent of permuted statistics 

pr=cell(2,1);
pl=cell(2,1);

lb=cell(2,1);
ub=cell(2,1);

hyp=cell(2,1);

for ba=1:2
    
    x=w{ba};
    xp=wp{ba};
    
    nc=length(x);
    if type==1
        alpha=0.05./nc;
    else
        alpha=0.05/nc;
    end
    idx=round(alpha*nperm)+1;
    
    lower_bound=zeros(nc,1);
    upper_bound=zeros(nc,1);
    p_right=zeros(nc,1);
    p_left=zeros(nc,1);
    h=zeros(nc,1);
    
    for i=1:nc
        
        sorted=sort(xp(i,:));
        lower_bound(i)=sorted(idx);
        upper_bound(i)=sorted(nperm-(idx));
        
        if x(i)<lower_bound(i)
            h(i)=1;
        elseif x(i)>upper_bound(i)
            
            h(i)=1;
        end
        
        p_right(i)=sum(x(i,1)<xp(i,:))/nperm;
        p_left(i)=sum(x(i,1)>xp(i,:))/nperm;
        
    end
    
    pr{ba}=p_right;
    pl{ba}=p_left;
    hyp{ba}=h;
    
    lb{ba}=lower_bound;
    ub{ba}=upper_bound;
    
end

%% percentage of significant neurons

for ba=1:2
    
    perc_significant=sum(hyp{ba})./length(hyp{ba})*100;
    display(perc_significant, ['percentage of significant neurons in ',namea{ba},namep{period}])
    
end

%% mean across groups of + and - neurons

for ba=1:2
     
    idx_pos=find(w{ba}>0.5);
    auc_pop_pos=mean(w{ba}(idx_pos));
    idx_neg=find(w{ba}<0.5);
    auc_pop_neg=mean(w{ba}(idx_neg));
    
end

%% test if weights are imbalanced (permutation test)

nstep=100;
if type==1
    support=linspace(0,1,nstep);
else
    support=linspace(-1.3,1.3,nstep);
end
pval=ones(2,1);
fcol=zeros(2,nstep);
for ba=1:2
    
    y=mean(w{ba});
    x0=mean(wp{ba});
    
    pval(ba)=sum(y<x0)/length(x0);
    pd=ksdensity(w{ba},support);
    fcol(ba,:)=pd./sum(pd);
    
    
end

hval=pval<0.05;
display(pval,'weights imbalanced?')

%% plot single neurons and distribution of weights

if type==1
    
    yt=[0.3,0.5,0.7];
    ylimit=[0.15,0.85];
    
else
    
    yt=[-1,0,1];
    ylimit=[-1.5,1.5];
    
end
dy=(ylimit(2)-ylimit(1))/(2*3);

pltidx2={[1,2],[4,5]};

H=figure('name',figname);
for ba=1:2
    
    y=w{ba};                                           
    nc=length(y);
    x=1:nc;
    z1=lb{ba}';
    z2=ub{ba}';
    
    mark=hyp{ba}-1+ylimit(1)+0.1*ylimit(2); 
    mark_sess=cumsum(ncell_sess{ba})+0.5;
    
    subplot(2,3,pltidx2{ba})
    hold on
    patch([x fliplr(x)], [z1 fliplr(z2)], gray,'FaceAlpha',0.5,'EdgeColor',gray)
    plot(0:nc+1,ones(nc+2).*bv(type),'color',[0.5,0.5,0.5],'linewidth',lw)          % 0.5 line
    plot(x,y,'+','color','k','markersize',ms,'linewidth',lw);                   
    plot(x,mark,'r.','markersize',ms+2)  % plot the significance
    
    for i=1:length(mark_sess)
        line([mark_sess(i), mark_sess(i)],[ylimit(1)+dy,ylimit(2)-dy],'Color','k','LineStyle','-.')
    end
    
    hold off
    
    box off
    ylim(ylimit)
    xlim([0,nc+1])
    
    set(gca,'YTick',yt)
    set(gca,'XTick',40:40:nc)
    
    set(gca,'XTickLabel',40:40:nc,'FontName','Arial','fontsize',fs)
    if ba==2
        set(gca,'XTick',30:30:nc)
        set(gca,'XTickLabel',30:30:nc,'FontName','Arial','fontsize',fs)
    end
   
    
    set(gca,'YTickLabel',yt,'FontName','Arial','fontsize',fs)
    if ba==2
        xlabel ('Neuron index','FontName','Arial','fontsize',fs);
    end
    
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ydist=squeeze(fcol(ba,:));
    
    subplot(2,3,ba*3)
    hold on
    area(support(1:51),ydist(1:51),'FaceColor',blue)
    area(support(51:100),ydist(51:100),'FaceColor',red)
    line([bv(type),bv(type)],[0,0.12],'color',[0.2,0.2,0.2,0.5],'linestyle','--','linewidth',lw)
    
    if hval(ba)==1
        plot(support(65),max(ydist)*1.3,'k*','markersize',ms+2)
    end
    hold off
    
    xlim(ylimit)
    ylim([0,max(ydist)*1.5])
    
    set(gca,'YTick',round((max(ydist)*1.5)/2*100)/100)
    set(gca,'YTickLabel',round((max(ydist)*1.5)/2*100)/100)
    if ba==1
        set(gca,'YTickLabel',[])
    end
    set(gca,'XTick',yt)
    set(gca,'XTickLabel',[])
    
    if ba==2
        ylabel('Prob. distribution','FontName','Arial','fontsize',fs)
    end
    
    view([90 -90])
    text(1.05,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
    
    
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
end

axes
%text(-0.08,1.05,letter{type}, 'units','normalized', 'FontName','Arial','fontsize',fs,'FontWeight','Bold')
h2 = ylabel (longname{type},'units','normalized','Position',[-0.09,0.5,0],'FontName','Arial','fontsize',fs); 
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

