% plot weights of the linear SVM in first (second) half of the window, and
% in the whole window
% similarity with linear correlation coeff

clear all
close all
clc

period=1;

savefig=0;
window=1;

namea={'V1','V4'};
namep={'target','test'};
namew={'first_half','second_half'};

pos_vec=[0,0,12,10];
figname=['weights_whole_',namew{window}];
savefile='/home/veronika/Dropbox/struct_pop/figure/weights/';


lw=1.2;
ms=5;
fs=10;
lwa=1;

blue=[0,0.48,0.74];
%%

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
wind=cell(2,2);

for ba=1:2
    
    loadname=['svmw_',namea{ba},namep{period}];
    load(loadname)
    var=cellfun(@(x) permute (x,[2,1]),weight_all,'UniformOutput', false);
    wind{ba,1}=cell2mat(var);
    
    clear weight_all
    
    loadname=['svmw_',namew{window},'_',namea{ba},namep{period}];
    load(loadname)
    var=cellfun(@(x) permute (x,[2,1]),weight_all,'UniformOutput', false);
    wind{ba,2}=cell2mat(var);
    
    
   
end

%% test significance of the correlation coefficient
% && test difference of distributions

pval_dist=zeros(2,1);
pvalR=zeros(2,1);
R=zeros(2,1);
for ba=1:2
      
    x=wind{ba,1};
    y=wind{ba,2};
    [rho,p]=corr(x,y);
    R(ba)=rho;
    pvalR(ba)=p;
    
    [~,p]=ttest2(x,y);
    pval_dist(ba)=p;
    
end

%% plot

alpha=0.05;
col={'k','m'};
maxw=max(max(cellfun(@max,wind)));
xvec=linspace(-maxw,maxw,100);

textw={'first half','second half'};
ticks=-0.5:0.5:0.5;
yt=0.01:0.01:0.03;

dx=0.002;
delta=0.15;

H=figure('name',figname,'visible','on');
for ba=1:2
    
    x=wind{ba,1};
    y=wind{ba,2};    
   
    f=ksdensity(x,xvec);
    g=ksdensity(y,xvec);
    fnorm=f./sum(f);
    gnorm=g./sum(g);
    twonorm=cat(2,fnorm,gnorm);
    
    subplot(2,2,ba)
    hold on
    plot(xvec,fnorm,'color',blue,'Linewidth',lw)
    plot(xvec,gnorm,'color',col{window},'Linewidth',lw)
    
    [ymax,idxy]= max(gnorm);
    xm=xvec(idxy);
    ym=max(twonorm)+(0.1*max(twonorm));
    
    line([xm-delta,xm+delta],[ym, ym],'color','k')
    line([xm-delta,xm-delta],[ym-dx,ym],'color','k')
    line([xm+delta,xm+delta],[ym-dx,ym],'color','k')
    
    hold off
    
    if pval_dist(ba)<alpha/2
        th=text(xm-(delta/4),ym+1.5*dx,'*','color','k','fontsize',fs+3);
    else
        th=text(xm-(delta/2),ym+1.5*dx,'n.s.','color','k','fontsize',fs);
    end
    
    if ba==1
        
        text(0.1,0.9,'whole window','units','normalized','color',blue ,'FontName','Arial','fontsize',fs)
        text(0.1,0.8,textw{window},'units','normalized','color',col{window}, 'FontName','Arial','fontsize',fs)
        
    end
    
    set(gca,'XTick',ticks)
    set(gca,'XTickLabel',ticks, 'FontName','Arial','fontsize',fs)
    set(gca,'YTick',yt)
    if ba==1
        set(gca,'YTickLabel',yt, 'FontName','Arial','fontsize',fs)
    else
        set(gca,'YTickLabel',[])
    end
    
    title(namea{ba}, 'FontName','Arial','fontsize',fs, 'Fontweight','normal')
    xlim([xvec(1), xvec(end)])
    ylim([0,0.04])
    grid on
    xlabel('Weights','FontName','Arial','fontsize',fs)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    subplot(2,2,ba+2)
    hold on
    plot(x,y,'k.','markersize',ms)
    
    hl=lsline; % least squares line
    
    B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
    hl.Visible='off';
    Slope = B(2);
    Intercept = B(1);
    xnew=linspace(-xvec(end)*0.9,xvec(end)*0.9,length(x));
    linear_fit=Intercept+xnew.*Slope;
    plot(xnew,linear_fit,'b','linewidth',0.5)
    hold off
    
    text(0.1,0.9,['R = ' sprintf('%0.2f',R(ba))],'units','normalized', 'FontName','Arial','fontsize',fs)
    %{
    if pvalR(ba)<0.05/2
        text(0.03,0.9,'*','units','normalized','color','r','fontsize',fs+3)
    end 
    %}
    xlim([-1.1, 1.1])
    ylim([-1.1,1.1])
  
    box off
    
    line([-xvec(end)*0.9 xvec(end)*0.9],[0,0],'linestyle','--','color',[0.5,0.5,0.5])
    line([0,0],[-xvec(end)*0.9 xvec(end)*0.9],'linestyle','--','color',[0.5,0.5,0.5])
   
    set(gca,'XTick',ticks)
    set(gca,'YTick',ticks)
    set(gca,'XTickLabel',ticks, 'FontName','Arial','fontsize',fs)
    set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',fs)
    
    if ba==2
        set(gca,'YTickLabel',[])
    end   
    
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
end

axes

h1 = xlabel ('Weight first half','units','normalized','Position',[0.5,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Weight second half','units','normalized','Position',[-0.1,0.2,0],'FontName','Arial','fontsize',fs);
h3 = text (-0.13,0.6,'Probablity density','units','normalized','FontName','Arial','fontsize',fs,'Rotation',90);

set(gca,'Visible','off')

set(h1,'visible','on')
set(h2,'visible','on')
set(h3,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

