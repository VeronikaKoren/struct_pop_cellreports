% 

clear all
close all
clc

savefig=0;
period=2;
window=3;

namea={'V1','V4'};
namep={'target','test'};
namew={'','first_half_','second_half_'};


if window==1
    figname=['stpa_sign_',namep{period},namew{window}];
else
    figname=['stpa_sign_',namep{period},'_',namew{window}(1:end-1)];
end

savefile='/home/veronika/Dropbox/struct_pop/figure/sign/';

green=[0.2,0.7,0];
gray=[0.2,0.2,0.2];
col={green,gray};

pos_vec=[0 0 14 9];

fs=10;
ms=5;
lw=1.2;
lwa=1;

%% plot coupling of informative and uninformative neurons to the rest of the population


addpath('/home/veronika/synced/struct_result/coupling/sign/')

stpa=cell(2,2);
pval_all=zeros(2,1);

for ba=1:2
    
    
    loadname=['stp_sign_',namew{window},namea{ba},'_',namep{period},'.mat'];                   % load w_svm
    load(loadname)
    stpa{ba,1}=stp_within;
    stpa{ba,2}=stp_across;
    
    pval_all(ba)=pval;
    
end

speak=cellfun(@(x) x(:,iW),stpa,'UniformOutput',false);
display(pval_all,'p-values V1/V4 permutation test');

xvec=-iW+1:iW+1;
msyn=cellfun(@mean,speak);

%% plot

titles={'Coupling function','Peak eCDF','Average peak'};

yt=0:0.08:0.16;
ylimit=[-0.02,0.2];
dx=abs(ylimit(2)-ylimit(1))/18;

idxplt=[1,4];
H=figure('name',figname,'visible','off');

for ba=1:2
    
    y1=stpa{ba,1};
    y2=stpa{ba,2};
    
    z1=speak{ba,1};
    z2=speak{ba,2};
    
    [~,idx]=sort(z1);
    idx1=idx(end-7);
    [~,idx]=sort(z2);
    idx2=idx(end-7);
    
    subplot(2,3,idxplt(ba))
    hold on
    plot(xvec,y1(idx1,:),'color',col{1},'linewidth',lw+0.5);
    plot(xvec,y2(idx2,:),'color',col{2},'linewidth',lw);
    hold off
    
    xlim([-50,50])
    ylim(ylimit)
    grid on
    
    
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt, 'FontName','Arial','Fontsize',fs)
    set(gca,'XTick',[-iW,0,iW])
    if ba==1
        title(titles{1}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',[-50,0,50], 'FontName','Arial','Fontsize',fs)
        xlabel('lag (ms)', 'FontName','Arial','Fontsize',fs)
    end
    
    if ba==1
        text(0.1,0.7,'across','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
        text(0.1,0.85,'within','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
    end
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [f,x1]=ecdf(speak{ba,1});
    [g,x2]=ecdf(speak{ba,2});
    
    subplot(2,3,idxplt(ba)+1)
    hold on
    plot(x1,f,'color',col{1},'linewidth',lw)
    plot(x2,g,'color',col{2},'linewidth',lw)
    hold off
    
    grid on
    xlim([-0.01,0.2])
    set(gca,'XTick',yt)
    if ba==1
        title(titles{2}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',yt, 'FontName','Arial','Fontsize',fs)
        xlabel('coupling at 0 lag', 'FontName','Arial','Fontsize',fs)
    end
    
    %%
    subplot(2,3,idxplt(ba)+2)
    
    b=bar(msyn(ba,:));
    b.FaceColor = 'flat';
    b.CData(1,:)=col{1};
    b.CData(2,:) = col{2};
    b.FaceAlpha=0.7;
    
    ylim([0,0.1])
    box off
    grid on
    
    maxy=double(max(msyn(ba,:)));
    
    line([1,2],[maxy+dx,maxy+dx],'color','k')
    line([1,1],[maxy+dx,maxy+dx/2],'color','k')
    line([2,2],[maxy+dx,maxy+ dx/2],'color','k')
    
    if pval_all(ba)<0.05
        text(1.3,maxy+ 1.8*dx,'*','fontsize',fs+3)
    else
        text(1.1,maxy+1.8*dx,'n.s.','fontsize',fs)
    end
     
    set(gca,'YTick',[0.03,0.06])
    set(gca,'YTickLabel',[0.03,0.06],'FontName','Arial','Fontsize',fs)
    
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[]);
    
    
    if ba==1
        title(titles{3}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
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

