% 

clear all
close all
clc

savefig=0;
period=2;
window=1;

%%
namea={'V1','V4'};
namep={'target','test'};
namew={'','first_half_','second_half_'};

figname=['ccg_info_',namew{window},namep{period}];
savefile='/home/veronika/Dropbox/struct_pop/figure/info/';

orange=[1,0.3,0.05];
gray=[0.2,0.2,0.2];
col={ orange,gray};

pos_vec=[0 0 10 9];

fs=10;
ms=5;
lw=1.2;
lwa=1;

%% load ccg for group of informative and uninformative neurons

addpath /home/veronika/synced/struct_result/pairwise/ccg/ccg_info/

ccg=cell(2,2);
pval_all=zeros(2,1);

for ba=1:2
    
    loadname=['ccg_info_',namew{window},namea{ba},'_',namep{period},'.mat'];                   % load w_svm
    load(loadname)
    
    ccg{ba,1}=info_fun;
    ccg{ba,2}=notinfo_fun;
    pval_all(ba)=pval;
    
end
%%

iW=(size(ccg{1,1},2)+1)/2;
xvec=-iW+1:iW-1;

msmua=cellfun(@mean,ccg,'UniformOutput',false);
synchrony=cellfun(@(x) x(:,iW),ccg,'UniformOutput',false);
msyn=cellfun(@mean,synchrony);

%% compute the synchrony and the coefficient with delta=10 ms;

titles={'correlation function','peak'};

ylimit=[-0.01,0.1];
yt=0:0.03:0.06;

dx=abs(ylimit(2)-ylimit(1))/10;
idxp=[1,3];

H=figure('name',figname,'visible','on');

for ba=1:2
    
    y1=msmua{ba,1};
    y2=msmua{ba,2};
    
    subplot(2,2,idxp(ba))
    hold on
    plot(xvec,y1,'color',col{1},'linewidth',lw+1);
    plot(xvec,y2,'color',col{2},'linewidth',lw+0.5);
    
    xlim([-50,50])
    ylim(ylimit)
    
    grid on
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt, 'FontName','Arial','Fontsize',fs)
    if ba==1
        title(titles{1}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
    end
    if ba==2
        xlabel('lag (ms)', 'FontName','Arial','Fontsize',fs)
    end
    
    if ba==1
        text(0.05,0.69,'not info.','units','normalized','FontName','Arial','fontsize',fs,'color',gray)
        text(0.05,0.79,'info.','units','normalized','FontName','Arial','fontsize',fs,'color',orange)
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
    subplot(2,2,idxp(ba)+1)
    
    b=bar(msyn(ba,:));
    b.FaceColor = 'flat';
    b.CData(1,:)=col{1};
    b.CData(2,:) = col{2};
    b.FaceAlpha=0.7;
    
    maxy=double(max(msyn(ba,:)));
    
    line([1,2],[maxy+dx,maxy+dx],'color','k')
    line([1,1],[maxy+dx,maxy+dx/2],'color','k')
    line([2,2],[maxy+dx,maxy+dx/2],'color','k')
    
    if pval_all(ba)<0.05
        text(1.4,maxy+ 1.5*dx,'*','fontsize',fs+5,'FontName','Arial')
    else
        text(1.2,maxy+2*dx,'n.s.','fontsize',fs,'FontName','Arial')
    end
   
    ylim(ylimit) 
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',[])
   
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[])
     grid on
    box off
    if ba==1
        title(titles{2}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
    end
    text(1.05,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
end


axes;
%text(-0.13,1.05,letter{period}, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold')
h2 = ylabel ('Probability of coincident spikes','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

%%

