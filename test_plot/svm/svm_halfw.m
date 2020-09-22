% tests and plots the performance of the svm in the first and second half
% of the trial 

clear all
close all
clc
format long


savefig=0;
alpha=0.05; % significance level

%%

period=2;
namea={'V1','V4'};
namep={'target','test'};
figname='bac_half_window';
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

pos_vec=[0,0,11.4,8.5]; 

lw=1.0;
ms=6;
fs=10;
lwa=1;
green=[0.2,0.7,0];

%% load classification results

addpath('/home/veronika/synced/struct_result/classification/svm_window/')

acc=cell(2,1); 
accp=cell(2,1);
for ba=1:2
    
    loadname=['svm_window_regular',namea{ba},namep{period},'.mat'];
    load(loadname);
  
    acc{ba}=bac_halfw;        % balanced accuracy
    
    loadname2=['svm_window_permuted',namea{ba},namep{period},'.mat'];
    load(loadname2);
    
    accp{ba}=bac_halfwp;
    
end

addpath '/home/veronika/synced/struct_result/classification/svm_regular/'
loadname2='svm_session_order_test';
load(loadname2);

%% permutation test on the p-value, test difference of BAC

mean_diff=cellfun(@(x) mean(x(2,:)-x(1,:)), acc); % mean across sessions
mean_diffp=cellfun(@(x) squeeze(mean(x(2,:,:)-x(1,:,:))), accp,'UniformOutput', false);

mean_bac=cellfun(@(x) mean(x,2), acc,'UniformOutput',false); % mean across sessions
mean_accp=cellfun(@(x) squeeze(mean(x,2)),accp, 'UniformOutput', false);

%

p_val=ones(2,1);
for ba=1:2
    
    x=mean_diff(ba);
    x0=mean_diffp{ba};
    p_val(ba)=sum(x<x0)/length(x0); 
 
end

hyp=p_val < alpha/numel(p_val);
display(p_val,'p-val first vs. second part of the trial')

%% plot balanced accuracy: session mean and individual sessions

col={'k','m'};
idxp=[[1,2];[4,5]];

ymin=0.35;
ymax=0.85;
yt=0.4:0.1:0.7;
xt=[1,7,14;1,4,8];

H=figure('name',figname,'visible','on');

for ba=1:2
    
    subplot(2,3,idxp(ba,:))
    x1=acc{ba}(1,:);
    x2=acc{ba}(2,:);
  
    order=sess_order{ba};
    
    subplot(2,3,idxp(ba,:))
    
    hold on
    plot(0:length(x1)+1,ones(length(x1)+2,1).*0.5,'--','color',[0.2,0.2,0.2,0.5],'linewidth',lw-0.5)
    plot(x1(order),'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(x2(order),'x','color',col{2},'markersize',ms,'Linewidth',lw+1);
    
    hold off
    ax=[0,length(x1)+1,ymin,ymax];
    axis(ax)
    
    box off
    grid on
    
    if ba==1
        text(0.65,0.9,'first half','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
        text(0.65,0.8,'second half','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs)
   
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
       
end

%bars=zeros(2,2);
%bars(1,:)=mean_bac{1};
%bars(2,:)=mean_bac{2};

ylimit=[0.47,0.62];
dx=0.008;
yt2=0.5:0.05:0.55;

for ba=1:2
    
    y1=mean_bac{ba}(1);
    y2=mean_bac{ba}(2);
    x0=mean_accp{ba};
    
    subplot(2,3,ba*3)
    hold on
    
    plot(1,y1,'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(2,y2,'x','color',col{2},'markersize',ms,'Linewidth',lw+1);
    bs=boxplot(x0','colors',[0.5,0.5,0.5]);
    set(bs,{'linew'},{1})
    %bar(1,bars(ba,1),'FaceColor',[0.2,0.2,0.2],'EdgeColor','k','linewidth',2);
    %bar(2,bars(ba,2),'FaceColor',col{2},'EdgeColor',col{2},'linewidth',2);
    
    hold off
    grid on
    box off
    
    % draw significance lines
    xb=max([y1,y2])+3*dx;
    line([1,2],[xb, xb],'color','k')
    line([1,1],[xb-dx,xb],'color','k')
    line([2,2],[xb-dx,xb],'color','k')
    
    if p_val(ba)<alpha
        th=text(1.37,xb+dx,'*','fontsize',fs+2);
    else
        th=text(1.15,xb+1.5*dx,'n.s.','fontsize',fs);
    end
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    ylim(ylimit)
    xlim([0,3])
    
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[])
    
    set(gca,'YTick',yt2)
    text(1.05,0.5,namea{ba},'units','normalized')
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
end

axes

h1=xlabel ('Session index (sorted w.r.t. regular)','Position',[0.3,-0.08],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs); 
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'Visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end

