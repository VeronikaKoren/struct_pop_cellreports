% tests and plots difference between the regular model and the model with
% removed structure (homogeneous network)  within subpopulation of neurons with the same sign of
% the weight
% first and second half of the time window

format long

clear all
close all
clc

savefig=0;
period=2;

alpha=0.05;                                                                     

%%

namea={'V1','V4'};
namep={'target','test'};
namew={'_first_half','_second_half'};

figname='homogeneous_groups_windows';
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

pos_vec=[0,0,11.4,8.5];                                                            % figure size in cm [x_start, y_start, width, height]

lw=1.0;                                                                         % linewidth
ms=6;                                                                           % markersize
fs=10;                                                                          % fontsize
lwa=1;                                                                          % linewidth for figure borders

col={'k','m'};
%% load results of the regular model

addpath('/home/veronika/synced/struct_result/classification/svm_window/')
addpath('/home/veronika/synced/struct_result/classification/svm_homogeneous/')

acc=cell(2,2);                                                                  
acc_perm=cell(2,2);                                                           

acc2=cell(2,2); 
acc2_perm=cell(2,2);

for ba=1:2
    
    %%%%%%%%%%%%%%%%%%%%%% regular svm
    loadname=['svm_window_regular',namea{ba},namep{period},'.mat'];
    load(loadname);
    acc{ba,1}=bac_halfw(1,:)';
    acc{ba,2}=bac_halfw(2,:)';
    
    loadname0=['svm_window_permuted',namea{ba},namep{period},'.mat'];
    load(loadname0);
    acc_perm{ba,1}=squeeze(bac_halfwp(1,:,:));
    acc_perm{ba,2}=squeeze(bac_halfwp(2,:,:));
  
    clear bac_all
    clear bac_allp
    
    
    loadname2=['svm_groups_homogeneous_', namea{ba},namep{period},namew{1}];
    load(loadname2);
    
    acc2{ba,1}=bac_all;      
    acc2_perm{ba,1}=bac_allp;
    
    clear bac_all
    clear bac_allp
    
    loadname2=['svm_groups_homogeneous_', namea{ba},namep{period},namew{2}];
    load(loadname2);
    
    acc2{ba,2}=bac_all;      
    acc2_perm{ba,2}=bac_allp;
    
    clear bac_all
    clear bac_allp
    
end

addpath '/home/veronika/synced/struct_result/classification/svm_regular/'
loadname3='svm_session_order_test';
load(loadname3);

%% average across sessions
                                                
ma=cellfun(@mean, acc2);                                                                                         %  average across sessions
map=cellfun(@mean,acc2_perm,'UniformOutput', false);

%% test: BAC decreases with homogeneous groups compared to the regular model                    

p_val=zeros(2,2);

for ba=1:2
    for i=1:2
        x=ma(ba,i);
        x0=map{ba,i};
        
        p_val(ba,i)=sum(x<x0)/length(x0);
    end
end

%hyp=p_val<alpha/(numel(p_val));
display(p_val,'p-value perm. test on the hypothesis: homogeneous network performs better than chance')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot session average and results in individual sessions

yt=0.5:0.1:0.7; 
xt=[1,7,14;1,4,8];
ylimit=[0.4,0.8];

pltidx={[1,2],[4,5]};

H=figure('name',figname,'visible','on');

% plot results in session
for ba=1:2
    
    y1=acc2{ba,1};
    y2=acc2{ba,2};
    
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
        text(0.6,0.92,'first half','units','normalized','color',col{1},'fontsize',fs,'FontName','Arial')
        text(0.6,0.8,'second half','units','normalized','color',col{2},'fontsize',fs,'FontName','Arial')
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
    
    x=ma(ba,:);
    x0=cell2mat(map(ba,:)');
    
    subplot(2,3,pltidx(ba))
    hold on
    bs=boxplot(x0','colors',[0.5,0.5,0.5]);
    plot(1,x(1),'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(2,x(2),'x','color',col{2},'markersize',ms,'Linewidth',lw+1);
    set(bs,{'linew'},{0.75})
    plot(0:4,zeros(5,1),'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    grid on
    
    hold off
    
    text(1.05,0.5,namea{ba},'units','normalized', 'FontName','Arial','fontsize',fs)
    xlim([0.5,2.5])
    ylim(ylimit2)
    box off
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    set(gca,'YTick',yt2)
    set(gca,'YTickLabel',yt2,'fontsize',fs, 'FontName','Arial','fontsize',fs)  
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[])
  
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% difference w.r.t.the regular model

d_sess=cellfun(@(x,y) x-y, acc,acc2,'UniformOutput', false);                                                       % compute the difference bac_permuted - bac_regular 
d=cellfun(@mean, d_sess);                                                                                         %  average across sessions
d_perm=cellfun(@(x,y) x-y, acc_perm,acc2_perm,'UniformOutput',false);
dp=cellfun(@mean,d_perm,'UniformOutput', false);


%% test: removing structure within coding pools does not change classification performance w.r.t. the regular model                    

pval_diff=zeros(2,2);

for ba=1:2
    for i=1:2
        x=d(ba,i);
        x0=dp{ba,i};
        
        pval_diff(ba,i)=sum(x<x0)/length(x0);
    end
end

hyp=pval_diff<alpha/(numel(pval_diff));
display(pval_diff,'p-value perm. test on the hypothesis: BAC decreases with homogeneous groups')

