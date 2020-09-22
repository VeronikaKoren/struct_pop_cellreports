% plot balanced accuracy in sessions and average across sessions

format long

clear all
close all
clc

savefig=1;
period=2;

%%
pos_vec=[0,0,12,9]; 
namep={'target','test'};
namea={'V1','V4'};

savefile='/home/veronika/Dropbox/struct_pop/figure/task/range/';
figname=['range_sc_raw_',namep{period}];

lw=1.0;     % linewidth
ms=6;       % markersize
fs=10;      % fontsize
lwa=1;

%% load the results of the linear SVM

addpath '/home/veronika/synced/struct_result/classification/svm_regular/'
loadname2='svm_session_order_test';
load(loadname2);

addpath '/home/veronika/synced/struct_result/input/range/'

range=cell(2,1);  
ncell_sess=cell(2,1);
for ba=1:2
        
    
    loadname=['sc_range_raw_',namea{ba},namep{period},'.mat'];
    load(loadname);
    miniorder=minis(sess_order{ba});
    maxiorder=maxis(sess_order{ba});
    
    range{ba}=abs(cell2mat(maxiorder)-cell2mat(miniorder));
    
    ncell_sess{ba}=cellfun(@(x) size(x,1), miniorder);
    
end

%% test difference in range V1 vs. V4

[h,p]=ttest2(range{1},range{2});
display(p,'p-val t-test range V1 vs V4')

%% plot

nc=cellfun(@(x) length(x),range);
ncell_max=max(nc);
boxes=NaN(ncell_max,2);
boxes(:,1)=range{1};
boxes(1:nc(2),2)=range{2};

%%
violet=[0,0.3,1];
gray=[0.7,0.7,0.7];
col={'k',violet};

pltidx={[1,2],[4,5]};

maxy=max(cellfun(@max,range));

ylimit=[0 160];
yt=40:40:120;
dy=(ylimit(2)-ylimit(1))/(5);

H=figure('name',figname);
for ba=1:2
    
    y=range{ba}*2;
    nc=length(y);
    mark_sess=cumsum(ncell_sess{ba})+0.5;
    
    subplot(2,3,pltidx{ba})
    hold on
    plot(1:nc,y,'color',col{1},'linewidth',lw)
    
    for i=1:length(mark_sess)
        line([mark_sess(i), mark_sess(i)],[ylimit(1)+dy/2,ylimit(2)-2*dy],'Color',[0.5,0.5,0.5],'LineStyle','-.')
    end
    
    xlim([0 nc+1])
    ylim(ylimit)
    hold off
    grid on
    
    set(gca,'XTick',40:40:nc)
    set(gca,'XTickLabel',40:40:nc,'FontName','Arial','fontsize',fs)
    
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'FontName','Arial','fontsize',fs)
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
    if ba==2
        xlabel ('Neuron index','FontName','Arial','fontsize',fs);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(2,3,pltidx{ba}(2)+1)
    bs=boxplot(y,'colors',col{1});
    line([1-0.2,1+0.2], [mean(y) mean(y)],'color','m','Linewidth',lw)
    set(bs,{'linew'},{1})
    ylim(ylimit)
    box off
    grid on
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    set(gca,'XTick',1)
    set(gca,'XTickLabel',[])

    set(gca,'YTick',yt)
    set(gca,'YTickLabel',[])
    text(1.05,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
     
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes

h2 = ylabel ('Range of spike counts (spikes/sec)','units','normalized','Position',[-0.09,0.5,0],'FontName','Arial','fontsize',fs); 
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

