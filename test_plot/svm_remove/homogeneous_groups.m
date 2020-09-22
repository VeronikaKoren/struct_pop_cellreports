% plots the BAC of the regular model and the model with
% removed structure (homogeneous network)  within coding pools

format long

clear all
close all
clc

savefig=0;
  
period=2;
window=1;

alpha=0.05;                                                                     

%%
namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

figname='homogeneous_groups';
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

pos_vec=[0,0,11.4,8.5];                                                            % figure size in cm [x_start, y_start, width, height]

lw=1.0;                                                                         % linewidth
ms=6;                                                                           % markersize
fs=10;                                                                          % fontsize
lwa=1;                                                                          % linewidth for figure borders

%% load results of the regular model

addpath('/home/veronika/synced/struct_result/classification/svm_regular/')
addpath('/home/veronika/synced/struct_result/classification/svm_homogeneous/')

acc=cell(2,1);                                                                  
acc_perm=cell(2,1);                                                           

acc2=cell(2,1); 
acc2_perm=cell(2,1);

for ba=1:2
    
    loadname=['svm_regular_',namea{ba},namep{period},'.mat'];
    load(loadname);
   
    acc{ba}=bac_all;        
    acc_perm{ba}=bac_allp;
    
    clear bac_all
    clear bac_allp
    
    loadname2=['svm_groups_homogeneous_', namea{ba},namep{period},namew{window}];
    load(loadname2);
    
    acc2{ba}=bac_all;      
    acc2_perm{ba}=bac_allp;
    
    clear bac_all
    clear bac_allp
    
end

loadname3='svm_session_order_test';
load(loadname3);

%% average across sessions
mr=cellfun(@mean,acc);                                                
ma=cellfun(@mean, acc2);                                                                                         %  average across sessions
map=cell2mat(cellfun(@mean,acc2_perm,'UniformOutput', false));

%% test: BAC decreases with homogeneous groups compared to the regular model                    

p_val=zeros(2,1);

for ba=1:2
    
    x=ma(ba);
    x0=map(ba,:);
    
    p_val(ba)=sum(x<x0)/length(x0);    

end

hyp=p_val<alpha/(numel(p_val));
display(p_val,'p-value perm. test on the hypothesis: homogeneous within groups performs better than chance')

%% test: is homogeneous worse than the regular

d=cellfun(@(x,y) mean(x-y),acc,acc2);
d0=cellfun(@(x,y) mean(x-y),acc_perm,acc2_perm,'UniformOutput', false);

pval_diff=zeros(2,1);
for ba=1:2
    
    x=d(ba);
    x0=d0{ba};
    
    pval_diff(ba)=sum(x<x0)/length(x0);
    
end

display(pval_diff,'p-value perm. test on the hypothesis: regular model performs better than the homogeneous model')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot session average and results in individual sessions

yt=0.5:0.1:0.7; 
xt=[1,7,14;1,4,8];
ylimit=[0.4,0.8];

pltidx={[1,2],[4,5]};
col={'k','r'};

H=figure('name',figname,'visible','on');

% plot results in session
for ba=1:2
    
    y1=acc{ba};
    y2=acc2{ba};
    
    order=sess_order{ba};
    
    subplot(2,3, pltidx{ba})
    hold on
    plot(y1(order),'+','color',col{1},'markersize',ms,'Linewidth',lw+0.5);
    plot(y2(order),'x','color',col{2},'markersize',ms,'Linewidth',lw+0.5);
    plot(0:length(y1)+1,zeros(length(y1)+2,1),'--','color',[0.2,0.2,0.2,0.7],'linewidth',lw)
    hold off
    
    xlim([0,length(y1)+1])
    ylim(ylimit)
    box off
    
    if ba==1
        text(0.25,0.92,'regular','units','normalized','color',col{1},'fontsize',fs,'FontName','Arial')
        text(0.25,0.8,'homogeneous within pools','units','normalized','color',col{2},'fontsize',fs,'FontName','Arial')
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'XTickLabel',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs)
    grid on
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
     
end

yt2=[0.5,0.55];
ylimit2=[0.5,0.61];
pltidx=[3,6];
dx=0.004;

% plot average across sessions
for ba=1:2
    
    sess_average=[mr(ba),ma(ba)];
    
    subplot(2,3,pltidx(ba))
    hold on
    for i=1:2
        bar(i,sess_average(i),'FaceColor',col{i},'EdgeColor',col{i},'linewidth',2);
    end
    hold off
    
    box off
    grid on
    
    xb=max(sess_average)+3*dx;
    line([1,2],[xb, xb],'color','k')
    line([1,1],[xb-dx,xb],'color','k')
    line([2,2],[xb-dx,xb],'color','k')
    
    if pval_diff(ba)<alpha
        th=text(1.33,xb+dx,'*','color','k','fontsize',fs+3);
    else
        th=text(1.2,xb+2*dx,'n.s.','color','k','fontsize',fs);
    end
   
    
    xlim([0,3])
    ylim(ylimit2)
    
    set(gca,'XTick',[])
    set(gca,'YTick',yt2)
    set(gca,'YTickLabel',yt2,'fontsize',fs, 'FontName','Arial','fontsize',fs) 
      
    text(1.05,0.5,namea{ba},'units','normalized', 'FontName','Arial','fontsize',fs)
  
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
      
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


