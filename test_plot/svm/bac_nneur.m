% plot balanced accuracy in sessions and average across sessions

format long

clear all
close all
clc

type=1;

savefig=0;
period=2;

namep={'target','test'};
namea={'V1','V4'};
namet={'regular','homogeneous'};

savefile='/home/veronika/Dropbox/struct_pop/figure/classification/';
figname='performance_nn';


lw=1.0;     % linewidth
ms=6;       % markersize
fs=13;      % fontsize
lwa=1;

%% load the results of the linear SVM

addpath(['/home/veronika/synced/struct_result/classification/svm_',namet{type},'/'])
addpath '/home/veronika/synced/struct_result/classification/svm_singlen/'

acc=cell(2,1); % {area} (nbses,1);
accp=cell(2,1);
nn=cell(2,1);

for ba=1:2
        
    loadname=['svm_',namet{type},'_',namea{ba},namep{period},'.mat'];
    load(loadname);
    acc{ba}=bac_all;
    accp{ba}=bac_allp;
    
    clear bac_all
    loadname2=['svm_singlen_',namea{ba},namep{period},'.mat'];
    load(loadname2)
    nn{ba}=cellfun(@length, bac_all);
    
    clear bac_all
    
end

%%

nperm=size(accp{1},2);
r=zeros(2,1);
pval=zeros(2,1);

for ba=1:2
    
    x=acc{ba};
    y=nn{ba};
    r(ba)=corr(x,y);
    
    r0=zeros(nperm,1);
    for p=1:nperm
        x0=accp{ba}(:,p);
        r0(p)=corr(x0,y);
    end
    
    pval(ba)=sum(r(ba)<r0)/nperm;
    
end

%% plot

pos_vec=[0,0,7,9]; 
yt=0.5:0.1:0.7;
xt=5:5:15;

H=figure('name','bac_nn');
for ba=1:2
    subplot(2,1,ba)
    plot(nn{ba},acc{ba},'kx','markersize',ms)
    axis([3,20,0.43,0.78])
    box off
    
    set(gca,'XTick',xt)
    set(gca,'XTickLabel',xt,'fontsize',fs,'FontName','Arial')
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs,'FontName','Arial')
    text(0.97,0.5,namea{ba},'units','normalized','fontsize',fs,'FontName','Arial')
    
    op=get(gca,'OuterPosition');
    set(gca,'OuterPosition',[op(1)+0.1 op(2) op(3)-0.1 op(4)]); % OuterPosition = [left bottom width height]
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
end

axes

h1 = xlabel ('Number of neurons','Position',[0.5,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.06,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end


