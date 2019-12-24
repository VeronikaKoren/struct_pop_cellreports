% peak of the correlation function of the noise (synchrony) in V1 and V4,
% for whole time window, 1st and 2nd part of the trial

clear all
close all
clc

savefig=0;
period=2;

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

figname=['ccg_peak_info_windows_',namep{period}];
savefile='/home/veronika/Dropbox/struct_pop/figure/info/';

gray=[0.2,0.2,0.2];
orange=[1,0.3,0.05];
col={orange,gray};

pos_vec=[0 0 12 9];

fs=10;
ms=5;
lw=1.2;
lwa=1;

%% compute stats for group of informative and uninformative neurons

addpath('/home/veronika/synced/struct_result/pairwise/ccg/ccg_info/')

nv=length(namew);
peak1=cell(2,nv);
peak2=cell(2,nv);
pval_all=zeros(2,nv);

for ba=1:2
    for i=1:nv
        
        loadname=['ccg_info_',namea{ba},namep{period},namew{i},'.mat'];                   % load w_svm
        load(loadname)
        iW=(size(info_fun,2)+1)/2;
        peak1{ba,i}=info_fun(:,iW);
        peak2{ba,i}=notinfo_fun(:,iW);
        pval_all(ba,i)=pval;
        
    end
end

wm=cellfun(@mean,peak1);
am=cellfun(@mean, peak2);


%% plot the peak of the correlation function-synchrony

maxy=max(max(cat(1,wm,am)));
titles={'Entire window','First half','Second half'};
yt=[0.02,0.04];
ylimit=0.1;

H=figure('name',figname,'visible','on');
for ba=1:2
    
    maxl=max(cat(2,wm(ba,:),am(ba,:)));
    for i=1:nv
       
        x=wm(ba,i); % within
        y=am(ba,i); % accross
        
        peaks=cat(1,x,y);
        
        subplot(2,nv,i+(ba-1)*nv)
        hold on
        b=bar(peaks);
        b.FaceColor = 'flat';
        b.CData(1,:)=col{1};
        b.CData(2,:) = col{2};
        b.FaceAlpha=0.7;
        
        line([1,2],[maxl+maxl*0.2,maxl+maxl*0.2],'color','k')
        line([1,1],[maxl+maxl*0.2,maxl+maxl*0.1],'color','k')
        line([2,2],[maxl+maxl*0.2,maxl+maxl*0.1],'color','k')
        
        if pval_all(ba,i)<0.05
            text(1.35,maxl+0.25*maxl,'*','fontsize',fs+3)
        else
            text(1.15,maxl+0.4*maxl,'n.s.','fontsize',fs)
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
        
        if i==1
            set(gca,'YTickLabel',yt)
        else
            set(gca,'YTickLabel',[])
        end
        if ba==1
            title(titles{i}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        end
        if i==3
            text(1.05,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
        end
        set(gca,'LineWidth',lwa,'TickLength',[0.03 0.03]);
        
    end
end

axes;
  
h2 = ylabel ('Peak of the correlation functon','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

%%

