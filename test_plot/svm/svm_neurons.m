% plot balanced accuracy as afunction of the number of neurons in sessions and average across sessions

format long

clear all
close all
clc

savefig=0;
period=2;

%%
namep={'target','test'};
namea={'V1','V4'};

savefile='/home/veronika/Dropbox/struct_pop/figure/final/';
figname='bac_neurons';


lw=1.0;     % linewidth
ms=6;       % markersize
fs=10;      % fontsize
lwa=1;

%% load the results of the linear SVM

addpath '/home/veronika/synced/struct_result/classification/bac_nneur/'

sess_mean=cell(2,1);
sess_sem=cell(2,1);
big_mean=cell(2,1);
big_sem=cell(2,1);

for ba=1:2
    loadname=['nneur_',namea{ba},namep{period},'.mat'];
    load(loadname);
    
    sess_mean{ba}=bacn;
    sess_sem{ba}=bac_sem;
    big_mean{ba}=bac_average;
    big_sem{ba}=sem_average;
    
end
%%

pos_vec=[0,0,10.5,9]; 
yt=0.5:0.1:0.7;
yt2=0.5:0.05:0.6;
xt=5:5:15;
titles={'sessions','session average'};
maxyn=max([max(cellfun(@(x) size(x,1),sess_mean{1})),max(cellfun(@(x) size(x,1),sess_mean{2}))]);

%%

pltidx=[1,3];
H=figure('name',figname);
for ba=1:2
    
    y=sess_mean{ba};
    z=sess_sem{ba};
    nmax=max(cellfun(@(x) size(x,1),y));
    nbses=length(y);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    subplot(2,2,pltidx(ba))
    
    hold on
    for sess=1:nbses
        
        y1=(y{sess}-z{sess})';
        y2=(y{sess}+z{sess})';
        x=1:length(y1);
        patch([x fliplr(x)], [y1 fliplr(y2)], 'r','FaceAlpha',0.3,'EdgeColor','k')
        
        
    end
    hold off
    box off
    grid on
    
    xlim([1,maxyn+2])
    ylim([0.42,0.76])
    set(gca,'XTick',xt)
    
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs,'FontName','Arial')
    
    if ba==1
        title(titles{1},'fontsize',fs,'FontName','Arial','fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',xt,'fontsize',fs,'FontName','Arial')
    end
    
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    %%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    y1=(big_mean{ba} - big_sem{ba})';
    y2=(big_mean{ba} + big_sem{ba})';
    x=1:nmax;
    
    subplot(2,2,pltidx(ba)+1)
    patch([x fliplr(x)], [y1 fliplr(y2)], 'r','FaceAlpha',0.3,'EdgeColor','k')
    
    box off
    grid on
    xlim([1,maxyn+2])
    ylim([0.48,0.63])
    
    set(gca,'XTick',xt)
    
    set(gca,'YTick',yt2)
    set(gca,'YTickLabel',yt2,'fontsize',fs,'FontName','Arial')
    text(0.97,0.5,namea{ba},'units','normalized','fontsize',fs,'FontName','Arial')

    if ba==1
        title(titles{2},'fontsize',fs,'FontName','Arial','fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',xt,'fontsize',fs,'FontName','Arial')
    end
    
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
end

axes

h1 = xlabel ('Number of neurons','Position',[0.5,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end

