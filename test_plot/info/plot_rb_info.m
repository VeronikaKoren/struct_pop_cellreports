% 

clear all
close all
clc

savefig=1;
period=1;

namea={'V1','V4'};
namep={'target','test'};

figname=['rb_info_',namep{period}];
savefile='/home/veronika/Dropbox/struct_pop/figure/info/';

orange=[1,0.3,0.05];
gray=[0.2,0.2,0.2];
col={orange,gray};

pos_vec=[0 0 16 9];

fs=10;
ms=5;
lw=1.2;
lwa=1;

blv=[20,50,75,100];
n=length(blv);

%% plot noise corr of binned spike counts for different bin lengths


rbi=cell(n,2);
rbn=cell(n,2);
pval_all=zeros(n,2);

for i=1:n
    
    bin_length=blv(i);
    address= ['/home/veronika/synced/struct_result/pairwise/rb',sprintf('%1.0i',bin_length),'/info/'];
    addpath(address)
    
    for ba=1:2
        loadname=['r_info_',namea{ba},namep{period},'.mat'];                   % load w_svm
        load(loadname)
        
        rbi{i,ba}=info;
        rbn{i,ba}=notinfo;
        
        pval_all(i,ba)=pval;
    end
end

display(pval_all,'p-values V1/V4 permutation test');

%% plot


xt=0:0.2:0.4;
xlimit=[-0.15,0.58];
dx=abs(xlimit(2)-xlimit(1))/18;

H=figure('name',figname,'visible','on');

for ba=1:2
    
    for i=1:n
        [f,x1]=ecdf(rbi{i,ba});
        [g,x2]=ecdf(rbn{i,ba});
        
        subplot(2,4,i+(ba-1)*4)
        hold on
        plot(x1,f,'color',col{1},'linewidth',lw)
        plot(x2,g,'color',col{2},'linewidth',lw)
        hold off
        
        grid on
        xlim(xlimit)
        set(gca,'XTick',xt)
        if pval_all(i,ba)<0.05/4
            text(0.7,0.7,'*','units','normalized','color','k','fontsize',fs+3)
        end
        
        if i==n
            text(1.04,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
        end
        if ba==1
            title(['bin = ', sprintf('%1.0i',blv(i)),'ms'], 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
            set(gca,'XTickLabel',[])
        else
            set(gca,'XTickLabel',xt,'FontName','Arial','Fontsize',fs)
        end
        
        if and(ba==1,i==1)
            text(0.4,0.45,'less info','units','normalized','FontName','Arial','fontsize',fs,'color',gray)
            text(0.4,0.55,'info','units','normalized','FontName','Arial','fontsize',fs,'color',orange)
        end
        
    end 
end

axes;
h1 = xlabel('Noise correlation of binned spike trains', 'units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','Fontsize',fs);
h2 = ylabel ('Cumulative distribution function','units','normalized','Position',[-0.08,0.5,0],'FontName','Arial','fontsize',fs);

set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'Visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

%%

mi=cellfun(@(x) nanmean(x),rbi);
mn=cellfun(@(x) nanmean(x),rbn);
stdi=cellfun(@(x) nanstd(x)/sqrt(length(x)),rbi);
stdn=cellfun(@(x) nanstd(x)/sqrt(length(x)),rbn);

fs=16;
savefig2=1;
pos_vec2=[0,0,8,10];

figname2=['rb_info_averages_',namep{period}];

yt=[0,0.1];

H2=figure('name',figname2,'visible','on');

for ba=1:2
    
    subplot(2,1,ba)
    hold on
    y1=(mi(:,ba)-stdi(:,ba))';
    y2=(mi(:,ba)+stdi(:,ba))';
    patch([blv fliplr(blv)], [y1 fliplr(y2)], col{1},'FaceAlpha',0.3,'EdgeColor',col{1})
    
    z1=(mn(:,ba)-stdn(:,ba))';
    z2=(mn(:,ba)+stdn(:,ba))';
    patch([blv fliplr(blv)], [z1 fliplr(z2)], col{2},'FaceAlpha',0.3,'EdgeColor',col{2})
    
    hold off
    grid on
    
    axis([10,110,0,0.2])
   
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'FontName','Arial','Fontsize',fs)
    set(gca,'XTick',blv)
    if ba==1
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',blv,'FontName','Arial','Fontsize',fs)
    end
    
    text(1.02,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
    if ba==1
        text(0.1,0.7,'less info','units','normalized','FontName','Arial','fontsize',fs,'color',gray)
        text(0.1,0.85,'info','units','normalized','FontName','Arial','fontsize',fs,'color',orange)
    end
    
    op=get(gca,'OuterPosition');
    set(gca,'OuterPosition',[op(1) op(2)+0.03 op(3) op(4)-0.03]); % OuterPosition = [left bottom width height]
    
end

axes;
h1 = xlabel('Bin length (ms)', 'units','normalized','Position',[0.5,-0.05,0],'FontName','Arial','Fontsize',fs);
h2 = ylabel ('Noise correlation','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);

set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'Visible','on')

set(H2, 'Units','centimeters', 'Position', pos_vec)
set(H2,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig2==1
    saveas(H2,[savefile,figname2],'pdf');
end
