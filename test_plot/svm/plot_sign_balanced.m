% plot balanced accuracy in sessions and average across sessions

format long

clear all
close all
clc

savefig=0;
period=2;

namep={'target','test'};
namea={'V1','V4'};
namet={'plus','minus'};

savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

figname=['svm_sign_',namep{period}];
pos_vec=[0,0,11.4,8.5]; 

lw=1.0;     % linewidth
ms=6;       % markersize
fs=10;      % fontsize
lwa=1;

blue=[0,0.48,0.74];
gray=[0.7,0.7,0.7];
col={'r',blue};


%% load the results of the linear SVM

addpath('/home/veronika/synced/struct_result/classification/svm_sign/')

bac_sign=cell(2,1);
sessions=cell(2,1);
accp=cell(2,1);

for ba=1:2
        
    loadname=['svm_signbal_',namea{ba},namep{period},'.mat'];
    load(loadname);
    sessions{ba}=sess_use;
    bac_sign{ba}=cat(2,bac_plus,bac_minus);
 
    loadname2=['svm_signbalp_',namea{ba},namep{period},'.mat'];
    load(loadname2);
    
    accp{ba}=cell2mat(bac_signp);
    
end

addpath '/home/veronika/synced/struct_result/classification/svm_regular/'
loadname3='svm_session_order_test';
load(loadname3);

%%

sm=cellfun(@(x) nanmean(x),bac_sign,'UniformOutput',false);

smp=cellfun(@(x) squeeze(nanmean(x)),accp,'UniformOutput',false);
display(sm)
nperm=size(accp{2},2);

%% test with permutation test: BAC is significantly bigger than chance

pval=zeros(2,2);
for ba=1:2
    
    x0=smp{ba};
    for s=1:2
        
        x=sm{ba}(s); 
        pval(ba,s)=sum(x<x0)./length(x0);
    end
end
hyp=pval<(0.05/numel(pval));
display(pval,'p-value significance')

%% test if plus is better than minus

pval_diff=zeros(2,1);
for ba=1:2
    d=sm{ba}(1)-sm{ba}(2);
    d0=smp{ba}-0.5;
    pval_diff(ba)=sum(d<d0)./length(d0);
end

hyp_diff=pval_diff<0.05/numel(pval_diff);
display(pval_diff,'p-value difference plus minus');

%}
%% plot sessions and average


yt=0.4:0.1:0.6; % y tick
xt=[1,7,14;1,4,8];

pltidx={[1,2],[4,5]};

H=figure('name',figname,'visible','on');
for ba=1:2
    
    y1= bac_sign{ba}(:,1); 
    y2= bac_sign{ba}(:,2);
    
    sess_use=sessions{ba};
    order=sess_order{ba};
    
    nbses=length(order);
    reduced_order=zeros(length(sess_use),1);
    
    for i=1:length(sess_use)
        reduced_order(i)=find(sess_use(i)==order);
    end
    
    yred=zeros(nbses,2);
    yred(reduced_order,1)=y1;
    yred(reduced_order,2)=y2;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(2,3,pltidx{ba})
    hold on
    plot(1:nbses,yred(:,1),'x','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(1:nbses,yred(:,2),'+','color',col{2},'markersize',ms,'Linewidth',lw+1);
    plot(0:nbses+1,ones(nbses+2,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    hold off
    
    axis([0,nbses+1,0.35,0.75])
    box off
    grid on
    

    set(gca,'XTick',xt(ba,:))
    set(gca,'XTickLabel',xt(ba,:),'FontName','Arial','fontsize',fs)
    
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs,'FontName','Arial')
    
    if ba==1
        for s=1:2
            text(0.7,0.9-(s-1)*0.13,namet{s},'units','normalized','color',col{s},'fontsize',fs,'FontName','Arial')
        end
    end
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
end

yt=[0.50,0.55];
ylimit=[0.48,0.60];
xh=0.58;
dx=0.005;

ym=0.57;
dy=0.005;

for ba=1:2
     
    subplot(2,3,ba*3)
    hold on
    for s=1:2
        bar(s,sm{ba}(s),0.8,'FaceColor',col{s},'EdgeColor',col{s},'linewidth',2);
    end
    line([0,3],[0.5, 0.5],'color','k','LineStyle',':')
   
    xb = max(sm{ba}) + 4*dx;
    line([1,2],[xb, xb],'color','k')
    line([1,1],[xb-dx,xb],'color','k')
    line([2,2],[xb-dx,xb],'color','k')
    
    if hyp_diff(ba)==1
        th=text(1.33,xb+dx,'*','color','k','fontsize',fs+3);
    else
        th=text(1.2,xb+dx*1.5,'n.s.','color','k','fontsize',fs);
    end
    hold off
    
    text(1.03,0.5,namea{ba},'units','normalized','fontsize',fs,'FontName','Arial')
  
    ylim(ylimit)
    xlim([0,3])
    box off
    grid on
    
    
    set(gca,'XTick',1)
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',[])
    set(gca,'XTickLabel', [])
    
    set(gca,'YTickLabel',yt,'fontsize',fs)
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
   
end

axes

h1 = xlabel ('Session index (sorted w.r.t. regular)','Position',[0.3,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end

