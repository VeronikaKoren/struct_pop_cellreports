% 

clear all
close all
clc

savefig=0;
period=2;
window=1;

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

figname=['ccg_info_',namep{period},namew{window}];
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

gray=[0.2,0.2,0.2];
orange=[1,0.3,0.05];
col={orange,gray};

pos_vec=[0,0,11.4,8];

fs=10;
ms=5;
lw=1.2;
lwa=1;

%% 

addpath('/home/veronika/synced/struct_result/pairwise/ccg/ccg_info/')

ccg_fun=cell(2,2);
pval_all=zeros(2,1);

for ba=1:2
       
    loadname=['ccg_info_',namea{ba},namep{period},namew{window},'.mat'];                   % load w_svm
    load(loadname)
    
    ccg_fun{ba,1}=info_fun;
    ccg_fun{ba,2}=notinfo_fun;
    
    pval_all(ba)=pval;
  
end
%%

nlag=size(ccg_fun{1,1},2);
iW=(nlag+1)/2;
xvec=-iW+1:iW-1;

cpeak=cellfun(@(x) x(:,iW),ccg_fun,'UniformOutput',false);
msyn=cellfun(@mean, cpeak);

%% plot the correlation function, eCDF of peaks and the average peak


titles={'Correlation function','Peak eCDF','Average peak'};

yt=0:0.1:0.2;
ylimit=[-0.05,0.3];
dx=abs(ylimit(2)-ylimit(1))/30;

idxplt=[1,4];
H=figure('name',figname,'visible','on');

for ba=1:2
    
    y1=ccg_fun{ba,1};
    y2=ccg_fun{ba,2};
    
    z1=cpeak{ba,1};
    z2=cpeak{ba,2};
    
    nph=round(length(z1)/5);
    
    %[~,idx1]=max(z1);
    %[~,idx2]=max(z2);
    
    [~,idx]=sort(z1);
    idx1=idx(end-7);
    [~,idx]=sort(z2);
    idx2=idx(end-7);
    
    subplot(2,3,idxplt(ba))
    hold on
    plot(xvec,y1(idx1,:),'color',col{1},'linewidth',lw+0.5);
    plot(xvec,y2(idx2,:),'color',col{2},'linewidth',lw);
    
    xlim([-50,50])
    ylim(ylimit)
    
    grid on
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt, 'FontName','Arial','Fontsize',fs)
    if ba==1
        title(titles{1}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',[-50,0,50], 'FontName','Arial','Fontsize',fs)
    end
    if ba==2
        xlabel('lag (ms)', 'FontName','Arial','Fontsize',fs)
    end
    
    if ba==1
        text(0.1,0.7,'less info','units','normalized','FontName','Arial','fontsize',fs,'color',gray)
        text(0.1,0.85,'info','units','normalized','FontName','Arial','fontsize',fs,'color',orange)
    end
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [f,x1]=ecdf(cpeak{ba,1});
    [g,x2]=ecdf(cpeak{ba,2});
    
    subplot(2,3,idxplt(ba)+1)
    hold on
    plot(x1,f,'color',col{1},'linewidth',lw)
    plot(x2,g,'color',col{2},'linewidth',lw)
    hold off
    
    grid on
    xlim([ylimit(1),0.4])
    set(gca,'XTick',yt([1,3]))
    
    if ba==1
        title(titles{2}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',yt([1,3]), 'FontName','Arial','Fontsize',fs)
    end
    
    if ba==2
        xlabel('correlation at 0 lag', 'FontName','Arial','Fontsize',fs)
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

axes;
  
h2 = ylabel ('Probability of coincident spiking','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end

