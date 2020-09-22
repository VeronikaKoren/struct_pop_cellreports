% tests and plots the svm on single neurons: uniform pooling and best
% single neuron

clear all
close all
clc
format long

savefig=1;
period=2;

alpha=0.05;                 % significance threshold

%%

namea={'V1','V4'};
namep={'target','test'};

figname='fig2b';
%figname=['singlen_',namep{period}];
savefile='/home/veronika/Dropbox/struct_pop/figure/classification/';

pos_vec=[0,0,11.4,8.5]; % size of the figure in cm
lw=1.0;
ms=6;
fs=10;
lwa=1;

blue=[0,0.48,0.74];

%% load classification results

addpath('/home/veronika/synced/struct_result/classification/svm_singlen/')
single_average=cell(2,1);


for ba=1:2
   
    loadname=['svm_singlen_',namea{ba},namep{period},'.mat'];
    load(loadname);
    
    single_average{ba}=cellfun(@mean,bac_all);
    clear bac_all
end


%%

single_best=cell(2,1);
for ba=1:2
   
    loadname=['svm_singlenest_',namea{ba},namep{period},'.mat'];
    load(loadname);
    
    
    single_best{ba}=cellfun(@mean, bac_best_single);
    
end

%% session order

addpath '/home/veronika/synced/struct_result/classification/svm_regular/'
loadname3='svm_session_order_test';
load(loadname3);

%% test mean vs. best
%{
pval_mmax=zeros(2,1);
for ba=1:2
    x=single_average{ba};
    y=single_best{ba};
    [h,p]=ttest2(x,y);
    pval_mmax(ba)=p;
end
%}
%% plot uniform pooling and best single neuron

col={blue,'m','k'};
idxp=[[1,2];[4,5]];
yt=0.5:0.1:0.7;
xt=[1,7,14;1,4,8];

H=figure('name',figname,'visible','on');

for ba=1:2
    
    subplot(2,3,idxp(ba,:))
    
    nbses=length(single_average{ba});
    y=zeros(2,nbses);
  
    y(1,:)=single_average{ba};
    y(2,:)=single_best{ba};
    
    order=sess_order{ba};
    
    subplot(2,3,idxp(ba,:))
    hold on
    for i=1:2
        plot(y(i,order),'+','color',col{i},'markersize',ms,'Linewidth',lw+1);
    end
    plot(0:nbses+1,ones(nbses+2,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw-0.5)
    hold off
    
    axis([0,nbses+1,0.4,0.8])
    
    box off
    grid on
    
    if ba==1
        text(0.2,0.8,'average across neurons','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
        text(0.2,0.92,'best neuron','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs)
   
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
       
end

sess_average=[cellfun(@mean,single_average),cellfun(@mean, single_best)];
dx=0.005;
ylimit=[0.48,0.62];
yt2=0.5:0.05:0.6;

for ba=1:2
    
    subplot(2,3,ba*3)
    hold on
    for i=1:2
        bar(i,sess_average(ba,i),'FaceColor',col{i},'EdgeColor',col{i},'linewidth',2);
    end
    line([0,3],[0.5, 0.5],'color','k','LineStyle',':')
    hold off
    box off
    
    %{
    xb=max(sess_average(ba,:))+4*dx;
    line([1,2],[xb, xb],'color','k')
    line([1,1],[xb-dx,xb],'color','k')
    line([2,2],[xb-dx,xb],'color','k')
    
    if pval_mmax(ba)<alpha
        th=text(1.33,xb+dx,'*','color','k','fontsize',fs+3);
    else
        th=text(1.2,xb+dx*1.5,'n.s.','color','k','fontsize',fs);
    end
    %}
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[])
    
    ylim(ylimit)
    xlim([0,3])
    
    set(gca,'YTick',yt2)
    set(gca,'YTickLabel',yt2,'FontName','Arial','fontsize',fs)
    text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
    grid on
    
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

