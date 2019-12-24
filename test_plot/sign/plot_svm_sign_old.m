% plot balanced accuracy in sessions using results from cortical layers 

format long

clear all
close all
clc

savefig=1;
period=1;

namesign={'minus','plus'};
namea={'V1','V4'};
namep={'target','test'};
letter={'A','A'};

addpath('/home/veronika/struct_pop/result/classification/svm_tartest/sign_specific/')
savefile='/home/veronika/Dropbox/struct_pop/figure/sign/';

figname=['svm_sign_',namep{period}];
pos_vec=[0,0,12,9]; 

lw=1.0; % linewidth
ms=6; % markersize
fs=10; % fontsize
lwa=1;

green=[0.2,0.7,0];
blue=[0,0.48,0.74];
col={blue,'k'};

%% load the results svm on the column in V1 and V4 in sessions

acc=cell(2,1); % {area} (nbses,sign);
accp=cell(2,1); % {area} (nbses, nperm, sign)

for ba=1:2
    
    loadname=['svm_sign_',namea{ba},namep{period},'.mat'];
    load(loadname);
     
    acc{ba}=bac_sign;
    accp{ba}= bac_signp;
    
end

sm=cellfun(@(x) nanmean(x),acc,'UniformOutput',false);                % average across sessions
smp=cellfun(@(x) squeeze(nanmean(x)),accp,'UniformOutput',false);

%% test with permutation test

nperm=size(smp{1},1);
pval=zeros(2,2);
for ba=1:2
    for sn=1:2
        x=sm{ba}(sn);
        x0=smp{ba}(:,sn);
        pval(ba,sn)=sum(x<x0)./nperm;
    end
end
hyp=pval<(0.05/numel(pval));

%% test difference between plus and minus in the same area

pval_diff=zeros(2,1);
for ba=1:2
    
    x=abs(sm{ba}(2)-sm{ba}(1));
    x0=smp{ba}(:,2)-smp{ba}(:,1);
    pval_diff(ba)=sum(x<x0)./nperm;
    
end
hyp_diff=pval_diff<(0.05/numel(pval_diff));
display(pval_diff,'p-value permutation test')
%% plot sessions and average

xt=[1,7,14;1,4,8];
pltidx={[1,2],[4,5]};

H=figure('name',figname,'visible','on');
for ba=1:2
    
    x=squeeze(acc{ba}(:,1)); % minus
    y=squeeze(acc{ba}(:,2)); % plus
    
    idxnan_x=find(isnan(x));
    x(idxnan_x)=0;
    
    idxnan_y=find(isnan(y));
    y(idxnan_y)=0;
    [~,order]=sort(y);
    order=flip(order);
    x=x(order);
    y=y(order);
    
    subplot(2,3,pltidx{ba})
    hold on
    plot(1:length(x),x,'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(1:length(x),y,'x','color',col{2},'markersize',ms,'Linewidth',lw+1);
    
    plot(0:length(x)+1,ones(length(x)+2,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    hold off
    
    if period==1
        axis([0,length(x)+1,0.35,0.65])
        yt=0.4:0.1:0.6; % y tick
    else
        axis([0,length(x)+1,0.4,0.75])
        yt=0.5:0.1:0.7; 
    end
    
    box off
    grid on
    
    set(gca,'XTick',xt(ba,:))
    if ba==2
        set(gca,'XTickLabel',xt(ba,:),'FontName','Arial','fontsize',fs)
    end
    
    if ba==1
        text(0.3,0.89,'minus','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
        text(0.3,0.79,'plus','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
    end
    
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs,'FontName','Arial')
    
    if ba==1&&sn==1
        text(0.7,0.8,'minus','units','normalized','color',col{1},'fontsize',fs,'FontName','Arial')
        text(0.7,0.65,'plus','units','normalized','color',col{2},'fontsize',fs,'FontName','Arial')
    end
    if ba==2
        xlabel ('Session index (sorted)','FontName','Arial','fontsize',fs)
    end
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
end

yt=[0.50,0.55];
ylimit=[0.47,0.62];
xh=0.58;

dy=0.005;

for ba=1:2
     
    x=sm{ba};
    x0=smp{ba};
    
    if period==1
        ym=max(x)+0.05;
    else
        ym=max(x)+0.02;
    end
    
    subplot(2,3,ba*3)
    hold on
    bs=boxplot(x0,'colors',[0.5,0.5,0.5]);
    set(bs,{'linew'},{1})
    plot(1,x(1),'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(2,x(2),'x','color',col{2},'markersize',ms,'Linewidth',lw+1);
    plot(0:3,ones(4,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    
    % draw lines for testing the difference between plus and minus
    
    if sum(hyp(ba))>0
        line([1,2],[ym,ym],'color','k')
        line([1,1],[ym-dy,ym],'color','k')
        line([2,2],[ym-dy,ym],'color','k')
        if period==2
            if hyp_diff(ba)==1
                %th=text(0.56, d2(ba),'*','color','r','fontsize',fs+5);
                text(1.4,ym+0.01,'*','color','k','fontsize',fs+5)
            end
        else
            text(1.3,ym+0.01,'n.s.','color','k', 'fontsize',fs+2)
        end
    end
    hold off
    
    text(1.03,0.5,namea{ba},'units','normalized','fontsize',fs,'FontName','Arial')
  
    ylim(ylimit)
    xlim([0.5,2.5])
    box off
    grid on
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    set(gca,'XTick',1:2)
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',[])
    set(gca,'XTickLabel', [])
    
    if ba==2
        set(gca,'XTickLabel',namesign,'FontName','Arial','fontsize',fs)
    end
    set(gca,'YTickLabel',yt,'fontsize',fs)
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
   
end

axes
h0=text(-0.1,1.05,letter{period}, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold'); 
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end


%%
%{
pos_vec=[0,0,9,10]; 
figname='svm_sign_average';


H=figure('name',figname,'visible','on');
for ba=1:2
     
    x=sm{ba};
    x0=smp{ba};
    
    subplot(2,1,ba)
    hold on
    bs=boxplot(x0,'colors',[0.5,0.5,0.5]);
    set(bs,{'linew'},{1})
    plot(1:2,x,'kx','markersize',ms,'Linewidth',lw+1);
    plot(0:3,ones(4,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    
    % mark significantly better than chance
    
    for i=1:2
        if hyp(ba,i)==1
            plot(i-0.2,x(i),'r*','markersize',ms,'linewidth',1.0)
        end
    end
   
    % draw lines for testing the difference between plus and minus
    line([1,2],[ym,ym],'color','k')
    line([1,1],[ym-dy,ym],'color','k')
    line([2,2],[ym-dy,ym],'color','k')
    
    if hyp_diff(ba)==1
        plot(1.5,ym+0.01,'k*','markersize',ms,'linewidth',1.0)
    else
        text(1.5,ym+0.01,'n.s.','color','k', 'fontsize',fs+2)
    end
        
    hold off
    
    text(1.03,0.5,namea{ba},'units','normalized','fontsize',fs,'FontName','Arial')
  
    ylim(ylimit)
    xlim([0.5,2.5])
    box off
    grid on
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    set(gca,'XTick',1:2)
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',[])
    set(gca,'XTickLabel', [])
    
    if ba==2
        set(gca,'XTickLabel',namesign,'FontName','Arial','fontsize',fs)
    end
    set(gca,'YTickLabel',yt,'fontsize',fs)
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
   
end

axes
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.12,0.5,0],'FontName','Arial','fontsize',fs);
set(h2,'visible','on')
set(gca,'Visible','off')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
%}

