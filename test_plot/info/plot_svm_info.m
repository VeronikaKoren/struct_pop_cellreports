% plot balanced accuracy in sessions using results from cortical layers 

format long

clear all
close all
clc

savefig=1;
period=2;

figname='svm_info';
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

namet={'informative','not informative'};
namea={'V1','V4'};
namep={'target','test'};
%%

addpath('/home/veronika/synced/struct_result/classification/svm_info/')
addpath('/home/veronika/synced/struct_result/classification/svm_regular/')

pos_vec=[0,0,11.4,8.5]; 

lw=1.0; % linewidth
ms=6; % markersize
fs=10; % fontsize
lwa=1;

orange=[1,0.3,0.05];
gray=[0.7,0.7,0.7];
col={orange,'k'};

%% load the results svm on the column in V1 and V4 in sessions

acci=cell(2,1);
accn=cell(2,1);
accp=cell(2,1); 
acc_regular=zeros(2,1);

pval_diff=zeros(2,1);
for ba=1:2
    
    loadname=['svm_ri_',namea{ba},namep{period},'.mat'];
    load(loadname);
     
    acci{ba}=cellfun(@mean,bac_info);
    accn{ba}= cellfun(@mean,bac_noinfo);
    
    veci=mean(cell2mat(bac_info'),2);                                               % average across sessions
    vecn=mean(cell2mat(bac_noinfo'),2);                                             
    [h,p]=ttest2(veci,vecn);                                                        % t-test
    pval_diff(ba)=p;
    
    loadname=['svm_regular_',namea{ba},namep{period},'.mat'];
    load(loadname);
    acc_regular(ba)=nanmean(bac_all);
    
    accp{ba}=bac_allp;
    
end

addpath '/home/veronika/synced/struct_result/classification/svm_regular/'
loadname3='svm_session_order_test';
load(loadname3);

display(pval_diff,'p-value permutation test info is better than not info')

%% average across sessions

mi=cellfun(@(x) nanmean(x),acci);               % 
mn=cellfun(@(x) nanmean(x),accn);
smp=cellfun(@(x) squeeze(nanmean(x)),accp,'UniformOutput',false);

average=cat(2,mi,mn);

%% test with permutation test

nperm=size(smp{1},1);
pval=zeros(2,2);
for ba=1:2
    for sn=1:2
        x=average(ba,sn);
        x0=smp{ba}(:,sn);
        pval(ba,sn)=sum(x<x0)./nperm;
    end
end
display(pval,'p-value permutation test info/less info is better than chance');
hyp=pval<(0.05/numel(pval));

%% plot sessions and average

titles={'informative','less informative'};

xt=[1,7,14;1,4,8];
pltidx={[1,2],[4,5]};

H=figure('name',figname,'visible','on');
for ba=1:2
    
    x=acci{ba}; % info
    y=accn{ba}; % not info
    
    
    order=sess_order{ba};
    
    subplot(2,3,pltidx{ba})
    hold on
    plot(1:length(x),x(order),'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(1:length(x),y(order),'x','color',col{2},'markersize',ms,'Linewidth',lw+1);
    
    plot(0:length(x)+1,ones(length(x)+2,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    hold off
    
    xlim([0,length(x)+1]);
    ylim([0.4,0.78])
    yt=0.5:0.1:0.7; 
    
    box off
    grid on
    
    set(gca,'XTick',xt(ba,:))
    if ba==2
        set(gca,'XTickLabel',xt(ba,:),'FontName','Arial','fontsize',fs)
    end
    
    if ba==1
        text(0.3,0.89,titles{1},'units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
        text(0.3,0.78,titles{2},'units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
    end
    
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs,'FontName','Arial')
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
end

yt=[0.50,0.55];
ylimit=[0.45,0.63];
xh=0.58;

dy=0.005;

for ba=1:2
     
    x=average(ba,:);
    x0=[smp{ba};smp{ba}]';
    
    ym=max(x)+0.02;
    
    subplot(2,3,ba*3)
    hold on
    
    bs=boxplot(x0,'colors',[0.5,0.5,0.5]);
    set(bs,{'linew'},{1})
    
    plot(1,x(1),'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(2,x(2),'x','color',col{2},'markersize',ms,'Linewidth',lw+1);
    plot(0:3,ones(4,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    
    % draw lines for testing the difference between info/not info
    line([1,2],[ym,ym],'color','k')
    line([1,1],[ym-dy,ym],'color','k')
    line([2,2],[ym-dy,ym],'color','k')
    
    if pval_diff(ba)<0.05/2
        text(1.42,ym+2*dy,'*','fontsize',fs+3) 
    else
        text(1.3,ym+2*dy,'n.s.', 'fontsize',fs+2)
    end    
    hold off
    
    text(1.03,0.5,namea{ba},'units','normalized','fontsize',fs,'FontName','Arial')
  
    ylim(ylimit)
    xlim([0.5,2.5])
    box off
    grid on
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    set(gca,'XTick',1:2)
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',[])
    set(gca,'XTickLabel', [])
    
    set(gca,'YTickLabel',yt,'fontsize',fs)
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
   
end

axes
h1 = xlabel ('Session index (sorted w.r.t. regular)','Position',[0.3,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end

%%

pval_regi=zeros(2,1);
for ba=1:2
    
    x=acc_regular(ba);
    y=average(ba,1);
    
    d=x-y;
    d0=smp{ba}(:,1)-0.5;
    pval_regi(ba)=sum(d>d0)./nperm;
    
end
display(pval_regi,'p-value permutation test that regular model is better than info');
hyp=pval_regi<(0.05/numel(pval_regi));

