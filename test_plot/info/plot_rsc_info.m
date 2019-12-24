% 

clear all
close all
clc

savefig=0;
period=2;
%cond=1;

namea={'V1','V4'};
namep={'target','test'};
%namec={'nm','m'};

figname=['rsc_info_',namep{period}];
savefile='/home/veronika/Dropbox/struct_pop/figure/info/';

orange=[1,0.3,0.05];
gray=[0.2,0.2,0.2];
col={orange,gray};

pos_vec=[0 0 10 9];

fs=10;
ms=5;
lw=1.2;
lwa=1;

%% plot coupling of informative and uninformative neurons to the rest of the population

addpath '/home/veronika/synced/struct_result/pairwise/rsc/rsc_info/'

variable=cell(2,2);
pval_all=zeros(2,1);


for ba=1:2
    
    loadname=['rsc_info_',namea{ba},namep{period},'.mat'];                   % load w_svm
    load(loadname)
    
    variable{ba,1}=imat;
    variable{ba,2}=nmat;
    if period==1
        [h,p]=ttest2(imat,nmat,'tail','left');
    else
        [h,p]=ttest2(imat,nmat,'tail','right');
    end
    pval_all(ba)=p;
    
end

display(pval_all,'p-values V1/V4 kolmogorov-smirnov test');
meancorr=cellfun(@mean, variable);

%% plot

titles={'eCDF','Average peak'};

yt=0:0.2:0.4;
yt2=0:0.1:0.3;
ylimit=[-0.15,0.58];
ylimit2=[0,0.33];
dx=abs(ylimit(2)-ylimit(1))/18;

idxplt=[1,3];
H=figure('name',figname,'visible','on');

for ba=1:2
    
   
    [f,x1]=ecdf(variable{ba,1});
    [g,x2]=ecdf(variable{ba,2});
    
    subplot(2,2,idxplt(ba))
    hold on
    plot(x1,f,'color',col{1},'linewidth',lw)
    plot(x2,g,'color',col{2},'linewidth',lw)
    hold off
    
    grid on
    xlim(ylimit)
    set(gca,'XTick',yt)
    if ba==1
        title(titles{1}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',yt)
    end
    
    if ba==2
        xlabel('noise correlation', 'FontName','Arial','Fontsize',fs)
    end
    if ba==1
        text(0.1,0.75,'not info','units','normalized','FontName','Arial','fontsize',fs,'color',gray)
        text(0.1,0.88,'info','units','normalized','FontName','Arial','fontsize',fs,'color',orange)
    end
    
    %%
    
    subplot(2,2,idxplt(ba)+1)
    
    b=bar(meancorr(ba,:));
    b.FaceColor = 'flat';
    b.CData(1,:)=col{1};
    b.CData(2,:) = col{2};
    b.FaceAlpha=0.7;
    
    ylim(ylimit2)
    box off
    grid on
    
    maxy=double(max(meancorr(ba,:)));
    
    line([1,2],[maxy+dx,maxy+dx],'color','k')
    line([1,1],[maxy+dx,maxy+dx/2],'color','k')
    line([2,2],[maxy+dx,maxy+ dx/2],'color','k')
    
    if pval_all(ba)<0.05
        text(1.4,maxy+ 1.5*dx,'*','fontsize',fs+3)
    else
        text(1.25,maxy+1.7*dx,'n.s.','fontsize',fs)
    end
     
    set(gca,'YTick',yt2)
    set(gca,'YTickLabel',yt2,'FontName','Arial','Fontsize',fs)
    
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[]);
    
    
    if ba==1
        title(titles{2}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
    end
    text(1.05,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
end

set(H, 'Units','centimeters', 'Position', pos_vec)
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

%%

