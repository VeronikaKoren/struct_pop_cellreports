clear all
close all
clc
format long

savefig=0;
period=2;

alpha=0.05;

%%
namea={'V1','V4'};
names={'within','across'};
namep={'target','test'};

% fig settings

pos_vec=[0 0 12 9];
green=[0.2,0.7,0];
gray=[0.2,0.2,0.2];
col={green,gray};

savefile='/home/veronika/Dropbox/struct_pop/figure/sign/';

ms=6;
fs=10;
lwa=1;
lw=1.7;

figname=['rb_sign_binL_',namep{period}];
disp(figname);

%%
L_vec=[20,50,75,100];
nv=length(L_vec);

pval_all=ones(2,nv);
within_all=cell(2,nv);
across_all=cell(2,nv);

for ba=1:2
  
    for i=1:length(L_vec)
        
        L=L_vec(i);
        
        addpath(['/home/veronika/synced/struct_result/pairwise/rb',sprintf('%1.0i',L),'/sign/'])
        loadname=['rb_sign',sprintf('%1.0i',L),'_',namea{ba}, '_', namep{period}];
        load(loadname)
        
        within_all{ba,i}=within;
        across_all{ba,i}=across;
        pval_all(ba,i)=pval;
    end
    
end

%% average across pairs;
wm=cellfun(@(x) nanmean(x),within_all);
am=cellfun(@(x) nanmean(x),across_all);

%%
maxy=max(max(cat(1,wm,am)));
dx=0.02;
yt=[0.05,0.1,0.15];
ylimit=0.2;

H=figure('name',figname,'visible','on');
for ba=1:2
    
    for i=1:nv
        maxl=max(cat(2,wm(ba,i),am(ba,i)));
        x=wm(ba,i); % within
        y=am(ba,i); % accross
        
        cats=cat(1,x,y);
        
        subplot(2,nv,i+(ba-1)*nv)
        hold on
        b=bar(cats);
        b.FaceColor = 'flat';
        b.CData(1,:)=col{1};
        b.CData(2,:) = col{2};
        b.FaceAlpha=0.7;
        
        line([1,2],[maxl+dx,maxl+dx],'color','k')
        line([1,1],[maxl+dx,maxl+dx/2],'color','k')
        line([2,2],[maxl+dx,maxl+dx/2],'color','k')
        if pval_all(ba,i)<0.05
            text(1.3,maxl+(1.2*dx),'*','fontsize',fs+3)
        else
            text(1.08,maxl+(1.8*dx),'n.s.','fontsize',fs)
        end
        hold off
        box off
        
        if and(ba==1,i==1)
            text(0.05,0.92,'same pool','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
            text(0.05,0.82,'different pools','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
        end
        
        ylim([0,maxy+0.4*maxy])
        ylim([0,ylimit])
        
        set(gca,'YTick',yt)
        set(gca,'YTickLabel',yt, 'FontName','Arial','Fontsize',fs)
        
        set(gca,'XTick',[1,2])
        set(gca,'XTickLabel',[]);
        xtickangle(35)
        
        if i==1
            set(gca,'YTickLabel',yt)
        else
            set(gca,'YTickLabel',[])
        end
        if ba==1
            title(['bin=',sprintf('%1.0i',L_vec(i)),' ms'], 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        end
        if i==nv
            text(1.05,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
        end
        set(gca,'LineWidth',lwa,'TickLength',[0.03 0.03]);
        
    end
end

axes;
%text(-0.12,1.05,letter{ba,period}, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold')    
h2 = ylabel ('Noise correlation of binned spike counts','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

