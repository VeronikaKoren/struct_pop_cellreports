% 

clear all
close all
clc

savefig=0;
period=2;

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

figname=['ccg_info_windows_',namep{period}];
savefile='/home/veronika/Dropbox/struct_pop/figure/info/';

gray=[0.2,0.2,0.2];
orange=[1,0.3,0.05];
pos_vec=[0 0 12 9];

fs=10;
ms=5;
lw=1.2;
lwa=1;

letter={'B','B'};

%% compute stats for group of informative and uninformative neurons

addpath('/home/veronika/synced/struct_result/pairwise/ccg/ccg_info/')

nv=length(namew);
group1=cell(2,nv);
group2=cell(2,nv);

for ba=1:2
    for i=1:nv
        
        loadname=['ccg_info_',namea{ba},namep{period},namew{i},'.mat'];                   % load w_svm
        load(loadname)
        
        group1{ba,i}=info_fun;
        group2{ba,i}=notinfo_fun;
        
    end
end

%% mean across pairs

wfun=cellfun(@mean,group1,'UniformOutput',false);
afun=cellfun(@mean,group2,'UniformOutput',false);
%% plot the correlation function rccg noise


titles={'Entire window','First half','Second half'};
col={orange,gray};
ylimit=[-0.01,0.08];
yt=0:0.02:0.06;


idxp=[1,3];
H=figure('name',figname,'visible','on');

for ba=1:2
    for i=1:nv
        
        y1=wfun{ba,i};
        y2=afun{ba,i};
        iW=(length(y1)+1)/2;
        xvec=-iW+1:iW-1;
        xt=[-50,0,50];
        
        subplot(2,nv,i+(ba-1)*nv)
        hold on
        plot(xvec,y1,'color',col{1},'linewidth',lw+1.5);
        plot(xvec,y2,'color',col{2},'linewidth',lw+0.5);
        hold off
        
        grid on
        xlim([xt(1),xt(end)])
        ylim(ylimit)
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt)
        if i==1
            set(gca,'YTickLabel',yt, 'FontName','Arial','Fontsize',fs)
        else
            set(gca,'YTickLabel',[])
        end
        if ba==1
            title(titles{i}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
            set(gca,'XTickLabel',[])
        else
            set(gca,'XTickLabel',xt, 'FontName','Arial','Fontsize',fs)
        end
        if i==3
            text(1.03,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
        if and(ba==1,i==1)
            text(0.05,0.89,'info','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
            text(0.05,0.75,'not info','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
        end
        set(gca,'LineWidth',lwa,'TickLength',[0.03 0.03]);
        
    end
end

axes;
%text(-0.1,1.05,letter{period}, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold')
h1 = xlabel('lag (ms)', 'units','normalized','Position',[0.5,-0.06,0],'FontName','Arial','Fontsize',fs);
h2 = ylabel ('Probability of coincident spikes','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);

set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'Visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end



%%

