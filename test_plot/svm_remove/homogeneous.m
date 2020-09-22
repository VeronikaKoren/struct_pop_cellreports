% tests and plots difference between the regular model and the model with
% removed structure across the entire population

format long

clear all
close all
clc

savefig=1;
                                                             
period=2;
alpha=0.05;                                                                     

%%

namea={'V1','V4'};
namep={'target','test'};

figname='fig2a';
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

pos_vec=[0,0,11.4,8.5];                                                            % figure size in cm [x_start, y_start, width, height]

lw=1.0;                                                                         % linewidth
ms=6;                                                                           % markersize
fs=10;                                                                          % fontsize
lwa=1;                                                                          % linewidth for figure borders

green=[0.2,0.7,0];
blue=[0,0.48,0.74];
gray=[0.7,0.7,0.7];
col={blue};

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
    
    loadname2=['svm_homogeneous_', namea{ba},namep{period}];
    load(loadname2);
    
    acc2{ba}=bac_all;      
    acc2_perm{ba}=bac_allp;
    
    clear bac_all
    clear bac_allp
    
end

loadname3='svm_session_order_test';
load(loadname3);

%% difference w.r.t.the regular model

d_sess=cellfun(@(x,y) x-y, acc2,acc,'UniformOutput', false);                                                       % compute the difference bac_permuted - bac_regular 
d=cellfun(@mean, d_sess);                                                                                         %  average across sessions
d_perm=cellfun(@(x,y) x-y, acc2_perm,acc_perm,'UniformOutput',false);
dp=cell2mat(cellfun(@mean,d_perm,'UniformOutput', false));

%% test: removing structure decreases classification performance                     

p_val=zeros(2,1);

for ba=1:2
    
    x=d(ba);
    x0=dp(ba,:);
    
    p_val(ba)=sum(x>x0)/length(x0);    

end

hyp=p_val<alpha/(numel(p_val));
display(p_val,'p-value perm. test on the hypothesis: removing structure decreases classification performance')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot session average and results in individual sessions

ylimit=[-0.2,0.2];
yt=-0.1:0.1:0.1;
xt=[1,7,14;1,4,8];
pltidx={[1,2],[4,5]};


H=figure('name',figname,'visible','on');

% plot results in session
for ba=1:2
    
    y2=d_sess{ba};

    order=sess_order{ba};
    y0=d_perm{ba}(order,:);
    
    subplot(2,3, pltidx{ba})
    hold on
    bs=boxplot(y0','colors',[0.5,0.5,0.5]);
    plot(y2(order),'+','color',col{1},'markersize',ms,'Linewidth',lw+0.5);
    plot(0:length(y2)+1,zeros(length(y2)+2,1),'--','color',[0.2,0.2,0.2,0.7],'linewidth',lw)
    hold off
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    xlim([0,length(y2)+1])
    ylim(ylimit)
    box off
    
    if ba==1
        text(0.1,0.92,'homogeneous','units','normalized','color',col{1},'fontsize',fs,'FontName','Arial')
        text(0.1,0.8,'permuted label','units','normalized','color',[0.5,0.5,0.5,0.5],'fontsize',fs,'FontName','Arial')
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'XTickLabel',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt*100,'fontsize',fs)
    grid on
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
     
end

yt=-0.05:0.05:0.05;
ylim2=[-0.08,0.08];
pltidx=[3,6];

% plot average across sessions
for ba=1:2
    
    x=d(ba);
    x0=dp(ba,:);
    
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
    ylim(ylim2)
    box off
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt*100,'fontsize',fs, 'FontName','Arial','fontsize',fs)  
    set(gca,'XTick',1)
    set(gca,'XTickLabel',[])
  
    
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
      
end

axes
h1 = xlabel ('Session index (sorted w.r.t. regular)','Position',[0.3,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Difference in accuracy w.r.t. regular (percent)','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end


