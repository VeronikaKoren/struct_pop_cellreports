% plot balanced accuracy in sessions using results from cortical layers 

format long

clear all
close all
clc

savefig=0;
period=2;

figname='svm_info';
savefile='/home/veronika/Dropbox/struct_pop/figure/info/';

namet={'not informative','informative'};
namea={'V1','V4'};
namep={'target','test'};

%%

addpath('/home/veronika/synced/struct_result/classification/svm_info/')
addpath('/home/veronika/synced/struct_result/classification/svm_regular/')

pos_vec=[0,0,12,9]; 

lw=1.0; % linewidth
ms=6; % markersize
fs=10; % fontsize
lwa=1;

green=[0.2,0.7,0];
blue=[0,0.48,0.74];
orange=[1,0.3,0.05];
gray=[0.7,0.7,0.7];
col={'k',orange};

%% load the results svm on the column in V1 and V4 in sessions

acci=cell(2,1);
accn=cell(2,1);
accp=cell(2,1); 

for ba=1:2
    
    loadname=['svm_ri_',namea{ba},namep{period},'.mat'];
    load(loadname);
     
    acci{ba}=cellfun(@mean,bac_info);
    accn{ba}= cellfun(@mean,bac_noinfo);
    
    loadname=['svm_regular_',namea{ba},namep{period},'.mat'];
    load(loadname,'bac_allp');
    
    accp{ba}=bac_allp;
    
end

%% average across sessions

mi=cellfun(@(x) nanmean(x),acci);               % 
mn=cellfun(@(x) nanmean(x),accn);
smp=cellfun(@(x) squeeze(nanmean(x)),accp,'UniformOutput',false);

averages=cat(2,mi,mn);

%% test with permutation test

nperm=size(smp{1},1);
pval=zeros(2,2);
for ba=1:2
    for sn=1:2
        x=averages(ba,sn);
        x0=smp{ba}(:,sn);
        pval(ba,sn)=sum(x<x0)./nperm;
    end
end
hyp=pval<(0.05/numel(pval));

%% plot sessions and average

namets={'not info.', 'info.'};

xt=[1,7,14;1,4,8];
pltidx={[1,2],[4,5]};

H=figure('name',figname,'visible','on');
for ba=1:2
    
    x=acci{ba}; % informative
    y=accn{ba}; % not informative
    
    % remove NaNs
    idxnan_x=find(isnan(x));
    x(idxnan_x)=0;
    idxnan_y=find(isnan(y));
    y(idxnan_y)=0;
    
    % order from smallest to biggest
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
        yt=0.4:0.1:0.6; 
        ylim([0.4,0.65])
    else
        axis([0,length(x)+1,0.35,0.75])
        yt=0.4:0.1:0.7; 
        ylim([0.4,0.78])
    end
    
    box off
    grid on
    
    set(gca,'XTick',xt(ba,:))
    if ba==2
        set(gca,'XTickLabel',xt(ba,:),'FontName','Arial','fontsize',fs)
    end
    
    if ba==1
        text(0.3,0.89,namet{2},'units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
        text(0.3,0.78,namet{1},'units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
        
    end
    
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs,'FontName','Arial')
    
    
    if ba==2
        xlabel ('Session index (sorted)','FontName','Arial','fontsize',fs)
    end
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
end

yt=[0.50,0.55];
ylimit=[0.45,0.63];
xh=0.58;


dy=0.005;

for ba=1:2
     
    x=averages(ba,:)
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
    
    % draw marks of significance the difference between info/not info
    %{
    line([1,2],[ym,ym],'color','k')
    line([1,1],[ym-dy,ym],'color','k')
    line([2,2],[ym-dy,ym],'color','k')
    
    if hyp_diff(ba)==1
        text(1.4,ym+0.01,'*','fontsize',fs+3) 
    else
        text(1.3,ym+0.01,'n.s.', 'fontsize',fs+2)
    end
    %}
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
        set(gca,'XTickLabel',namets,'FontName','Arial','fontsize',fs)
        %xtickangle(25)
    end
    set(gca,'YTickLabel',yt,'fontsize',fs)
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
   
end

axes
h0=text(-0.15,1.05,letter{period}, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold'); 
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.08,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end


