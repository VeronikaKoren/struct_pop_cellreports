% plot weights of the linear SVM on spike counts with and without
% correlations
% similarity with linear correlation coeff

clear all
close all
clc

period=2;
savefig=0;

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

pos_vec=[0,0,12,10];
figname='wrn_scatter';
savefile='/home/veronika/Dropbox/struct_pop/figure/weights/';


lw=1.2;
ms=5;
fs=10;
lwa=1;

%%

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')

wind=cell(2,3);
for ba=1:2
    
    for i=1:3
        loadname=['svmw',namew{i},'_',namea{ba},namep{period}];
        load(loadname)
        var=cellfun(@(x) permute (x,[2,1]),weight_all,'UniformOutput', false);
        wind{ba,i}=cell2mat(var);
        
    end
     
end
clear weight_all
%%

addpath('/home/veronika/synced/struct_result/weights/weights_rn/')

wind_rn=cell(2,3);
for ba=1:2
    
    for i=1:3
        loadname=['svmw_rn',namew{i},'_',namea{ba},namep{period}];
        load(loadname)
        wind_rn{ba,i}=cell2mat(weight_all);
        
    end
     
end

%% compute the correlation coefficient
% & test difference of distributions

pval_dist=zeros(2,3);
pvalR=zeros(2,3);
R=zeros(2,3);
for ba=1:2
    
    for i=1:3
        
        x=wind{ba,i};
        y=wind_rn{ba,i};
        [rho,p]=corr(x,y);
        R(ba,i)=rho;
        pvalR(ba,i)=p;
        
        [~,p]=ttest2(x,y,'tail','right');
        pval_dist(ba,i)=p;
        
    end
    
end
display(pval_dist,'p-value one tailed t-test')
%% plot

alpha=0.05;

textw={'entire window','first half','second half'};
textrn={'regular','removed corr.'};

ticks=-1:1:1;

H=figure('name',figname,'visible','on');
for ba=1:2
    
    for i=1:3
        
        x=wind{ba,i};
        y=wind_rn{ba,i};
        
        
        subplot(2,3,i+(ba-1)*3)
        hold on
        
        plot(x,y,'k.','markersize',ms)
        
        hl=lsline; % least squares line
        
        B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
        hl.Visible='off';
        Slope = B(2);
        Intercept = B(1);
        xnew=linspace(-xvec(end)*0.9,xvec(end)*0.9,length(x));
        linear_fit=Intercept+xnew.*Slope;
        plot(xnew,linear_fit,'b','linewidth',0.5)
        hold off
        
        text(0.1,0.9,['R = ' sprintf('%0.2f',R(ba,i))],'units','normalized', 'FontName','Arial','fontsize',fs)
        %if pvalR(ba,i)<0.05/3
        %    text(0.03,0.9,'*','units','normalized','color','r','fontsize',fs+3)
        %end
        
        axis([-1.3,1.3,-1.3,1.3])
        
        box off
        
        line([-xvec(end)*0.9 xvec(end)*0.9],[0,0],'linestyle','--','color',[0.5,0.5,0.5])
        line([0,0],[-xvec(end)*0.9 xvec(end)*0.9],'linestyle','--','color',[0.5,0.5,0.5])
        
        set(gca,'XTick',ticks)
        set(gca,'YTick',ticks)
        set(gca,'XTickLabel',ticks, 'FontName','Arial','fontsize',fs)
        set(gca,'YTickLabel',ticks,'FontName','Arial','fontsize',fs)
        
        set(gca,'XTick',ticks)
        if ba==1
            set(gca,'XTickLabel',[])
        else
            set(gca,'XTickLabel',ticks, 'FontName','Arial','fontsize',fs)
        end
        
        if ba==1
            title(textw{i}, 'FontName','Arial','fontsize',fs, 'Fontweight','normal')
        end
        %
        
        grid on
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
end

axes

h1 = xlabel ('Weight regular','units','normalized','Position',[0.5,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Weight removed noise corr','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);

set(gca,'Visible','off')

set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

