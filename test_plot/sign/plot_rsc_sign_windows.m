
clear all
close all
clc
format long

savefig=1;
period=2;

alpha=0.05;

%%
namea={'V1','V4'};
names={'within','across'};
namep={'target','test'};
namew={'whole','first_half','second_half'};

% fig settings

pos_vec=[0 0 12 9];
green=[0.2,0.7,0];
col={green,'k'};

savefile='/home/veronika/Dropbox/struct_pop/figure/sign/';

ms=6;
fs=10;
lwa=1;
lw=1.7;

figname=['within_across_',namep{period},'_windows'];
disp(figname);
%%

nv=length(namew);
addpath('/home/veronika/synced/struct_result/pairwise/rsc/sign/')

pval_all=ones(2,nv);
within_all=cell(2,nv);
across_all=cell(2,nv);

for ba=1:2
    for i=1:3
        
        loadname=['rsc_sign_',namew{i},'_',namea{ba}, '_', namep{period}];
        load(loadname)
        
        within_all{ba,i}=within;
        across_all{ba,i}=across;
        pval_all(ba,i)=pval;
        
    end
end

display(pval_all, 'pval')

%% plot eCDF function for noise correlations within & across pools


titles={'Entire window','First half','Second half'};
yt=0:0.5:1;

H=figure('name',figname,'visible','on');
for ba=1:2
    for i=1:nv
        
        x=within_all{ba,i}; % within
        y=across_all{ba,i}; % accross
        
        [f,xvec1]=ecdf(x);
        [g,xvec2]=ecdf(y);
        
        subplot(2,nv,i+(ba-1)*nv)
        hold on
        plot(xvec1,f,'color',col{1},'linewidth',lw)
        plot(xvec2,g,'color',col{2},'linewidth',lw)
        hold off
        
        if and(ba==1,i==1)
            text(0.05,0.92,'same','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
            text(0.05,0.82,'different','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
        end
        grid on
        if pval_all(ba,i)<0.05
            text(0.1,0.7,'*','units','normalized','color','r','fontsize',fs+5,'FontName','Arial')
        end
        
        if ba==1
            title(titles{i}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        end
        
        xlim([-0.4,0.7])
        set(gca,'XTick',[0,0.5,1])
        if ba==1
            set(gca,'XTickLabel',[])
        else
            set(gca,'XTickLabel',[0,0.5,1])
            
        end
        set(gca,'YTick',yt)
        if i==1
            set(gca,'YTickLabel',yt)
        else
            set(gca,'YTickLabel',[])
        end
        if i==3
            text(1.02,0.5,namea{ba},'units','normalized','fontsize',fs,'FontName','Arial')
        end
        box off
        set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
        
    end
end

axes;
%text(-0.12,1.05,letter{ba,period}, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold')    
h2 = ylabel ('Empirical CDF','units','normalized','Position',[-0.07,0.5,0],'FontName','Arial','fontsize',fs);
h1 = xlabel ('Noise correlation of trial-to-trial variability','units','normalized','Position',[0.5,-0.07,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')

set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end


