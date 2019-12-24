% plot weights of the linear SVM on spike counts with and without
% correlations
% similarity with linear correlation coeff

clear all
close all
clc

period=2;
savefig=1;

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

pos_vec=[0,0,12,10];
figname=['wrn_',namep{period}];
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
    clear weight_all
     
end

%%

addpath('/home/veronika/synced/struct_result/weights/weights_rn/')

wind_rn=cell(2,3);
for ba=1:2
    
    for i=1:3
        loadname=['svmw_rn',namew{i},'_',namea{ba},namep{period}];
        load(loadname)
        wind_rn{ba,i}=cell2mat(weight_all);
        
    end
    clear weight_all
     
end

%% compute the correlation coefficient
% & test difference of distributions

%%

pval_dist=zeros(2,3);
pvalR=zeros(2,3);
R=zeros(2,3);
for ba=1:2
    
    for i=1:3
        
        x=wind{ba,i};
        y=wind_rn{ba,i};
        
        [~,p]=ttest2(x,y,'tail','right');
        pval_dist(ba,i)=p;
        
    end
    
end
display(pval_dist,'p-value one tailed t-test')

%% plot

alpha=0.05;
blue=[0,0.48,0.74];
col={'k',blue};

maxw=max(max(cellfun(@max,wind)));
xvec=linspace(-maxw,maxw,100);

textw={'entire window','first half','second half'};
textrn={'regular','removed corr.'};

ticks=-0.5:0.5:0.5;
yt=0.01:0.01:0.03;
dx=0.002;
delta=0.2;

H=figure('name',figname,'visible','on');
for ba=1:2
    
    for i=1:3
        
        x=wind{ba,i};
        y=wind_rn{ba,i};
        
        f=ksdensity(x,xvec);
        g=ksdensity(y,xvec);
        fnorm=f./sum(f);
        gnorm=g./sum(g);
        twonorm=cat(2,fnorm,gnorm);
        
        subplot(2,3,i+(ba-1)*3)
        hold on
        plot(xvec,fnorm,'color',col{1},'Linewidth',lw)
        plot(xvec,gnorm,'color',col{2},'Linewidth',lw)
        hold off
        
        [ymax,idxy]= max(fnorm);
        xm=xvec(idxy);
        ym=max(twonorm)+(0.1*max(twonorm));
        
        line([xm-delta,xm+delta],[ym, ym],'color','k')
        line([xm-delta,xm-delta],[ym-dx,ym],'color','k')
        line([xm+delta,xm+delta],[ym-dx,ym],'color','k')
        
        
        
        if pval_dist(ba,i)<alpha
            th=text(xm-delta/2,ym+1.5*dx,'*','color','k','fontsize',fs+3);
        else
            th=text(xm-delta,ym+1.5*dx,'n.s.','color','k','fontsize',fs);
        end
        %}
        if and(ba==1,i==1)
            for j=1:2
                text(0.1,0.9-0.1*(j-1),textrn{j},'units','normalized','color',col{j}, 'FontName','Arial','fontsize',fs)
            end
        end
        
        if i==3
            text(1.01,0.5,namea{ba},'units','normalized', 'FontName','Arial','fontsize',fs)
        end
        set(gca,'XTick',ticks)
        if ba==1
            set(gca,'XTickLabel',[])
        else
            set(gca,'XTickLabel',ticks, 'FontName','Arial','fontsize',fs)
        end
        set(gca,'YTick',yt)
        if i==1
            set(gca,'YTickLabel',yt, 'FontName','Arial','fontsize',fs)
        else
            set(gca,'YTickLabel',[])
        end
        if ba==1
            title(textw{i}, 'FontName','Arial','fontsize',fs, 'Fontweight','normal')
        end
        %
        xlim([xvec(1), xvec(end)])
        ylim([0,0.04])
        grid on
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
end

axes

h1 = xlabel ('Weight','units','normalized','Position',[0.5,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Probability density','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);

set(gca,'Visible','off')

set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

