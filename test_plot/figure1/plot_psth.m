% plot population psth for two monkeys separately and than concatenated


clear all
close all
clc

savefig=1;

namep={'target','delay','test'};
namea={'V1','V4'};

figname='pop_psth';
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';
pos_vec=[0,0,8.5,8];

fs=10;
lw=1.5;% linewidth for plots
lwb=3; % width for the black bar
lwa=1;

% gaussian kernel
xw=-10:10;
mu=0;
sigma=10;
w=exp((-(xw-mu).^2)./(2*sigma));

%% load results

addpath('/home/veronika/synced/struct_result/psth/')
load psth_V1
pop_v1=cellfun(@mean, psth_sess,'UniformOutput',false);
clear psth_sess
load psth_V4
pop_v4=cellfun(@mean, psth_sess,'UniformOutput',false);

%% convolution
v1c=cellfun(@(x) conv([ones(1,20)*x(1,1),x,ones(1,20)*x(1,end)],w,'same')./sum(w),pop_v1,'UniformOutput',false);
v4c=cellfun(@(x) conv([ones(1,20)*x(1,1),x,ones(1,20)*x(1,end)],w,'same')./sum(w),pop_v4,'UniformOutput',false);

v1cut=cellfun(@(x) x(21:end-20),v1c,'UniformOutput',false);
v4cut=cellfun(@(x) x(21:end-20),v4c,'UniformOutput',false);

psth_all=cell(2,2);
psth_all{1,1}=cat(1,v1cut{1,1},v1cut{2,1});
psth_all{1,2}=cat(1,v1cut{1,2},v1cut{2,2});
psth_all{2,1}=cat(1,v4cut{1,1},v4cut{2,1});
psth_all{2,2}=cat(1,v4cut{1,2},v4cut{2,2});

%% plot

Yt=[15,30,45];
Xt={[200,600],[100,500,900]};
xtl={[0,400],[-400,0,400]};

maxy=60;
ax=[0,1000,5,maxy];
xr=[200,500];
xw={200,[100,500]};
L=500;
col={'r','k'};

tit={'target','test'};

H=figure('name',figname);

for ba=1:2
    for ep=1:2
        
        subplot(2,2,ep+(ba-1)*2)
        hold on
        
        for c=1:2
            plot(psth_all{ba,ep}(c,:),'color',col{c},'linewidth',lw)
        end
        % yellow rectangle for the stim ON
        rectangle('position',[xr(ep) 10 300 45],'Linewidth',1.5,'Linestyle','-','EdgeColor',[1,1,0,0.3],'FaceColor',[1,1,0,0.2])
        
        % black bars to indicate windows used for analysis
        if ep==1 
            plot(xw{ep}:xw{1}+ L-1,ones(1,L)*9,'k','Linewidth',lwb)  % target
            if ba==1
                %text(xw{ep}+100,13,'target','fontsize',fs,'fontname','Arial')
            end
        elseif ep==2
            
            plot(xw{2}(2):xw{2}(2)+ L-1,ones(1,L)*9,'k','Linewidth',lwb) % test
            if ba==1
                %text(xw{2}(2)+100,13,'test','fontsize',fs,'fontname','Arial')
            end
        end
        hold off
        
        axis(ax)
        set(gca, 'YTick',Yt)
        set(gca,'XTick',Xt{ep})
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        
        if ba==2
            set(gca,'XTickLabel',xtl{ep},'fontsize',fs,'fontname','Arial')
        end
        
        if ep==1
            set(gca,'YTickLabel',Yt,'fontsize',fs,'fontname','Arial')
        end
        
        if ba==1
            title(tit{ep},'fontsize',fs,'fontname','Arial','fontweight','normal')
        end
        if ep==2
            text(1.02,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
        
        % write legend
        if ba==1 && ep==1
            text(0.43,0.8,'match','units','normalized','color',col{2},'fontsize',fs,'fontname','Arial')
            text(0.43,0.7,'non-match','units','normalized','color',col{1},'fontsize',fs,'fontname','Arial')
        end
        
        set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
        
    end
end

axes
%text(-0.12,1.05,'C', 'units','normalized', 'FontName','Arial','fontsize',fs,'FontWeight','Bold')
% axis labels
h2 = ylabel ('Spikes/sec','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
h1 = xlabel ('Time from stimulus onset (ms)','units','normalized','Position',[0.5,-0.07,0],'FontName','Arial','fontsize',fs);

set(gca,'Visible','off')
set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end


%%