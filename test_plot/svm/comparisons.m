% tests and plots the svm on single neurons: uniform pooling and best
% single neuron; best single neuron and the population model

clear all
close all
clc
format long

savefig=0;
period=2;

alpha=0.05; 

namea={'V1','V4'};
namep={'target','test'};

figname='uniform_vs_homogeneous';
figname2='max_singlen_vs_remove_noise';
savefile='/home/veronika/Dropbox/struct_pop/figure/classification/';

pos_vec=[0,0,12,9]; % size of the figure in cm
lw=1.0;
ms=6;
fs=10;
lwa=1;

blue=[0,0.48,0.74];

%% load results for single neurons

addpath('/home/veronika/synced/struct_result/classification/svm_singlen/')

single_average=cell(2,1);
single_max=cell(2,1);

for ba=1:2
   
    loadname=['svm_singlen_',namea{ba},namep{period},'.mat'];
    load(loadname);
    
    single_average{ba}=cellfun(@mean,bac_all);
    single_max{ba}=cellfun(@max,bac_all);
    
end

%% load result homogeneous

addpath('/home/veronika/synced/struct_result/classification/svm_homogeneous/')
pop_homo=cell(2,1);
pop_perm=cell(2,1); 

for ba=1:2
        
    loadname=['svm_homogeneous_',namea{ba},namep{period},'.mat'];
    load(loadname);
    
    pop_homo{ba}=bac_all;
    pop_perm{ba}= bac_allp;
 
end

homo_perm=cellfun(@mean, pop_perm,'UniformOutput', false); % average avross sessions

%% permutation test: homogeneous model vs. uniform pooling

pval=ones(2,1);
for ba=1:2
    d=mean(single_average{ba})-mean(pop_homo{ba});
    d0=homo_perm{ba}-0.5;
    pval(ba)=sum(d<d0)/length(d0);
end

hyp=pval<(0.05/numel(pval));
display(hyp,'hypothesis')
display(pval,'p-value V1/V4: best single neuron is better than the population model')


%% plot uniform pooling and homogeneous network model

col={'k',blue};
idxp=[[1,2];[4,5]];
yt=0.5:0.1:0.7;
xt=[1,7,14;1,4,8];

H=figure('name',figname,'visible','on');

for ba=1:2
    
    subplot(2,3,idxp(ba,:))
    nbses=length(single_average{ba});
    
    y=zeros(2,nbses);
    y1=single_average{ba};
    [val,order]=sort(y1);
    new_order=flip(order);
    
    y(1,:)=y1(new_order);
    y(2,:)=pop_homo{ba}(new_order);
    
    subplot(2,3,idxp(ba,:))
    hold on
    for i=1:2
        plot(y(i,:),'+','color',col{i},'markersize',ms,'Linewidth',lw+1);
    end
    plot(0:length(y1)+1,ones(length(y1)+2,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw-0.5)
    hold off
    
    axis([0,length(y1)+1,0.4,0.8])
    
    box off
    grid on
    
    if ba==1
        text(0.4,0.82,'uniform pooling','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
        text(0.4,0.92,'homogeneous model','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs)
   
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
       
end
%%
sess_average=[cellfun(@mean,single_average),cellfun(@mean, single_max)];

ylimit=[0.45,0.65];
dx=0.005;
yt2=0.4:0.1:0.7;

for ba=1:2
    
    subplot(2,3,ba*3)
    hold on
    for i=1:2
        bar(i,sess_average(ba,i),'FaceColor',col{i},'EdgeColor',col{i},'linewidth',2);
    end
    line([0,3],[0.5, 0.5],'color','k','LineStyle',':')
    hold off
    box off
    
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[])
    
    ylim(ylimit)
    xlim([0,3])
    
    set(gca,'YTick',yt2)
    text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
    
end

axes
h1 = xlabel ('Session index (sorted w.r.t. uniform)','Position',[0.3,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs); 
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

%% test best single neurons vs the population model
best_single=sess_average(:,2);

addpath('/home/veronika/synced/struct_result/classification/svm_regular/')
pop_homo=cell(2,1);
pop_perm=cell(2,1); 

for ba=1:2
        
    loadname=['svm_regular_',namea{ba},namep{period},'.mat'];
    load(loadname);
    
    pop_homo{ba}=bac_all;
    pop_perm{ba}= bac_allp;
 
end
%%
homo_model=cellfun(@mean, pop_homo);
homo_perm=cellfun(@mean, pop_perm,'UniformOutput', false);

%% permutation test: best single neuron is more accurate than the population model

pval=ones(2,1);
for ba=1:2
    d=best_single(ba)-homo_model(ba);
    d0=homo_perm{ba}-0.5;
    pval(ba)=sum(d<d0)/length(d0);
end

hyp=pval<(0.05/numel(pval));
display(pval,'p-value V1/V4: best single neuron is better than the population model')

%%
col={'k','m',blue};
idxp=[[1,2];[4,5]];
yt=0.5:0.1:0.7;
xt=[1,7,14;1,4,8];

H2=figure('name',figname2,'visible','on');

for ba=1:2
    
    subplot(2,3,idxp(ba,:))
    nbses=length(single_max{ba});
    
    y=zeros(2,nbses);
    y1=pop_homo{ba};
    [val,order]=sort(y1);
    new_order=flip(order);
    
    y(1,:)=y1(new_order);
    y(2,:)=single_max{ba}(new_order);
    
    subplot(2,3,idxp(ba,:))
    hold on
    for i=1:2
        plot(y(i,:),'+','color',col{i},'markersize',ms,'Linewidth',lw+1);
    end
    plot(0:length(y1)+1,ones(length(y1)+2,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw-0.5)
    hold off
    
    axis([0,length(y1)+1,0.4,0.8])
    
    box off
    grid on
    
    if ba==1
        text(0.4,0.92,'population','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
        text(0.4,0.82,'best single neuron','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs)
   
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
       
end

bars=[homo_model,best_single];

ylimit=[0.5,0.65];
dx=0.005;
yt2=0.5:0.05:0.6;

for ba=1:2
    
    subplot(2,3,ba*3)
    hold on
    for i=1:2
        bar(i,bars(ba,i),'FaceColor',col{i},'EdgeColor',col{i},'linewidth',2);
    end
    line([0,3],[0.5, 0.5],'color','k','LineStyle',':')
    hold off
    box off
    
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[])
    
    xb=max(bars(ba,:))+4*dx;
    line([1,2],[xb, xb],'color','k')
    line([1,1],[xb-dx,xb])
    line([2,2],[xb-dx,xb])
    
    if pval(ba)<alpha
        th=text(1.33,xb+dx,'*','color','k','fontsize',fs+3);
    else
        th=text(1.2,xb+dx*1.5,'n.s.','color','k','fontsize',fs);
    end
    
    text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
    
    ylim(ylimit)
    xlim([0,3])
    
    set(gca,'YTick',yt2)
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
    
end

axes
h1 = xlabel ('Session index (sorted w.r.t. population model)','Position',[0.3,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs); 
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H2, 'Units','centimeters', 'Position', pos_vec) 
set(H2,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H2,[savefile,figname2],'pdf');
end


