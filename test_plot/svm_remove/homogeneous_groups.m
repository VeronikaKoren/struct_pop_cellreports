% tests and plots difference between the regular model and the model with
% removed structure (homogeneous network)  within subpopulation of neurons with the same sign of
% the weight

format long

clear all
close all
clc

savefig=0;
  
period=2;
window=1;

alpha=0.05;                                                                     

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

figname='homogeneous_groups';
savefile='/home/veronika/Dropbox/struct_pop/figure/classification/';

pos_vec=[0,0,12,9];                                                            % figure size in cm [x_start, y_start, width, height]

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

%% average across sessions
                                                
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
display(p_val,'p-value perm. test on the hypothesis: homogeneous network performs better than chance')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot session average and results in individual sessions

yt=0.5:0.1:0.7; 
xt=[1,7,14;1,4,8];
ylimit=[0.4,0.8];

pltidx={[1,2],[4,5]};
col={'k',[0.7,0.7,0.7,0.5]};

H=figure('name',figname,'visible','on');

% plot results in session
for ba=1:2
    
    y=acc{ba};
    [~,idx]=sort(y);
    order=flip(idx);
    y=y(order);
    y0=acc_perm{ba}(order,:);
    
    subplot(2,3, pltidx{ba})
    hold on
    bs=boxplot(y0','colors',[0.5,0.5,0.5]);
    plot(y,'+','color',col{1},'markersize',ms,'Linewidth',lw+0.5);
    plot(0:length(y)+1,zeros(length(y)+2,1),'--','color',[0.2,0.2,0.2,0.7],'linewidth',lw)
    hold off
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    xlim([0,length(y)+1])
    ylim(ylimit)
    box off
    
    if ba==1
        text(0.25,0.92,'homogeneous within pools','units','normalized','color',col{1},'fontsize',fs,'FontName','Arial')
        text(0.25,0.8,'permuted label','units','normalized','color',[0.5,0.5,0.5,0.5],'fontsize',fs,'FontName','Arial')
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'XTickLabel',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs)
    grid on
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
     
end

yt2=[0.50,0.55];
ylimit2=[0.47,0.60];
pltidx=[3,6];

% plot average across sessions
for ba=1:2
    
    x=ma(ba);
    x0=map(ba,:);
    
    subplot(2,3,pltidx(ba))
    hold on
    bs=boxplot(x0','colors',[0.5,0.5,0.5]);
    plot(1,x(1),'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    set(bs,{'linew'},{0.75})
    plot(0:4,zeros(5,1),'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    grid on
    
    hold off
    
    text(1.05,0.5,namea{ba},'units','normalized', 'FontName','Arial','fontsize',fs)
    xlim([0.5,1.5])
    ylim(ylimit2)
    box off
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    set(gca,'YTick',yt2)
    set(gca,'YTickLabel',yt2,'fontsize',fs, 'FontName','Arial','fontsize',fs)  
    set(gca,'XTick',1)
    set(gca,'XTickLabel',[])
  
    
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
      
end

axes
h1 = xlabel ('Session index (sorted)','Position',[0.3,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy (percent)','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

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
