
clear all
close all
clc

savefig=0;
period=2;

figname='weights_svm_roc_info';
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';


%%

namea={'V1','V4'};
namep={'target','test'};
names={'informative','less informative'};

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
addpath('/home/veronika/synced/struct_result/classification/auc_regular/')
addpath('/home/veronika/synced/struct_result/weights/tag/')

pos_vec=[0,0,11.4,9.5]; % size of the figure in cm

lw=1.2;
ms=5;
fs=10;
lwa=1;

orange=[1,0.3,0.05];
gray=[0.7,0.7,0.7];
col={orange,'k'};

%% load weights

w_svm=cell(2,1);
w_roc=cell(2,1);
tag=cell(2,1);

for ba=1:2
    
    loadname=['auc_',namea{ba},namep{period},'.mat'];                                                 % area under the ROC curve
    load(loadname);
    w_roc{ba}=cell2mat(cellfun(@(x) single(x), auc,'UniformOutput', false)) ;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    loadname2=['svmw_',namea{ba},namep{period},'.mat'];                                     % load w_svm
    load(loadname2)
    weight_all=cellfun(@(x) permute(single(x), [2,1]), weight_all, 'UniformOutput', false); % svm weights
    
    w_svm{ba}=cell2mat(weight_all);
    
    loadname3=['tag_info_',namea{ba},namep{period},'.mat'];                                     % load w_svm
    load(loadname3)
    
    tag{ba}=cell2mat(tag_info);
    
end

%% get deviation from the baseline

wabs=cellfun(@(x) abs(x),w_svm, 'UniformOutput', false);
wroc=cellfun(@(x) abs(x-0.5),w_roc, 'UniformOutput', false);

%% separate informative and less informative neurons

wrocs=cell(2,2);
wabss=cell(2,2);
for ba=1:2
    
    s=tag{ba};
    idx_info=find(s==1);
    idx_not=find(s==0);
    
    wrocs{ba,1}=wroc{ba}(idx_info);
    wrocs{ba,2}=wroc{ba}(idx_not);
    
    wabss{ba,1}=wabs{ba}(idx_info);
    wabss{ba,2}=wabs{ba}(idx_not);
    
end

%%
R=zeros(2,2);
for ba=1:2
    
    for i=1:2
        x=wrocs{ba,i};
        y=wabss{ba,i};
        
        R(ba,i)=corr(x,y);
        
    end 
end

Rr=round(R*1000)./1000;
display(Rr,'correlation coefficient')

%% plot

ax=[-0.02,0.24,-0.1,1.2];
xt=[0,0.1,0.2];
yt=[0,0.5,1];

H=figure('name',figname,'visible','on');
for ba=1:2
    
    for i=1:2
        
        subplot(2,2,i+(ba-1)*2)
        hold on
        
        plot(wrocs{ba,i},wabss{ba,i},'.','markersize',ms,'color',col{i})
        
        % least squares line
        hl=lsline;
        B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
        hl.Visible='off';
        Slope = B(2);
        Intercept = B(1);
        xnew=linspace(-0.1,0.2,length(x));
        linear_fit=Intercept+xnew.*Slope;
        plot(xnew,linear_fit,'k','linewidth',0.5)
        %}
        axis(ax)
        hold off
        grid on
        
        text(0.1,0.8,['R = ' sprintf('%0.3f',Rr(ba,i))],'units','normalized', 'FontName','Arial','fontsize',fs)
        if ba==1
            title(names{i},'fontweight','normal','FontName','Arial','fontsize',fs);
        end
        
        
        if i==2
            text(1.0,0.5,namea{ba},'units','normalized', 'FontName','Arial','fontsize',fs)
        end
        %}
        box off
        
        set(gca,'XTick',xt, 'FontName','Arial','fontsize',fs)
        set(gca,'YTick',yt,'FontName','Arial','fontsize',fs)
        set(gca,'XTickLabel',xt, 'FontName','Arial','fontsize',fs)
        set(gca,'YTickLabel',yt,'FontName','Arial','fontsize',fs)
        if ba==1
            set(gca,'XTickLabel',[])
        end
        if i>1
            set(gca,'YTickLabel',[])
        end
        
        set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    end
    
end

axes
h1 = xlabel ('Strength AUROC','units','normalized','Position',[0.5,-0.08],'FontName','Arial','fontsize',fs); 
h2 = ylabel ('Strength Weight SVM','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs); 

set(gca,'Visible','off')
set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end

