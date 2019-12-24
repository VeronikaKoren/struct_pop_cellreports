%% raster plot for 3 example neurons, one in each layer, during target and test
% different color are layers
% raster plot shows spike trains of a single neuron in trials

clear all
close all 
clc

ba=2;
condition=3; % 1 is correct non-match and 3 is correct match

namea={'V1','V4'};
namelay={'SG','G','IG'};

savefig=0;

figname='raster';
savefile='/home/veronika/Dropbox/struct_pop/figure/task/';
pos_vec=[0,0,8.5,9];

col={'m','k','b'};
namep={'target','test'};

fs=9;
ms=3;
lwa=1;

if ba==1
    dnames = '/home/veronika/v1v4/data/V1_all_all/';
else
    dnames = '/home/veronika/v1v4/data/V4_lay/';
end
fnames = dir([dnames filesep '*.mat']);

%%
nbses=length(fnames);

display(['choose session from 1 to ', sprintf('%i',nbses)])
session=4;

s=load([dnames filesep fnames(session).name]);

% take spike trains from a particular condition

if ba==1
    star=s.spikes_tar(condition,:);
    stest=s.spikes_test(condition,:);
else
    
    star=s.spikes_tarV4_lay(condition,:);
    stest=s.spikes_testV4_lay(condition,:);
end

nb_neur=size(star{1,1},2);

display(['choose a neuron from 1 to ', sprintf('%i',nb_neur)])
neuron=1;

% take spike trains of a particular neuron
ntar=cellfun(@(x) squeeze(x(:,neuron,:)),star,'UniformOutput',false);
ntest=cellfun(@(x) squeeze(x(:,neuron,:)),stest,'UniformOutput',false);

ntarp=cellfun(@(x) permute(x,[2,1]),ntar,'UniformOutput',false);
ntestp=cellfun(@(x) permute(x,[2,1]),ntest,'UniformOutput',false);

ntrial=size(ntar{1},1);

%% prepare raster plots

ntar_all=(cell2mat(reshape(ntar,3,1)))';
ntest_all=(cell2mat(reshape(ntest,3,1)))';

flip_order=flip(1:3*ntrial);
grid1=meshgrid(1:size(ntar_all,2),1:size(ntar_all,1));
grid2=meshgrid(1:size(ntest_all,2),1:size(ntest_all,1));
raster1=ntar_all(:,flip_order).*grid1;
raster2=ntest_all(:,flip_order).*grid2;

rasters=cell(2,1);
rasters{1}=raster1;
rasters{2}=raster2;
 
yt=[];
for k=1:3
     
    if ntrial>60
        vec=[20,40,60];
        ytick=vec+(k-1)*ntrial+1;
    else
        vec=[20,40];
        ytick=vec+(k-1)*ntrial+1;
    end
    
    yt=[yt,ytick];
end

%% plot

xtl=[0:300:600;-300:300:300];

H=figure('name',figname);
for i=1:2
    subplot(1,2,i)
    hold on
    plot(rasters{i}(:,1:ntrial),'.','color',col{1},'markersize',ms)
    plot(rasters{i}(:,ntrial+1:2*ntrial),'.','color',col{2},'markersize',ms)
    plot(rasters{i}(:,2*ntrial+1:3*ntrial),'.','color',col{3},'markersize',ms)
    
    hold off
    
    xr=200+(i-1)*300;
    rectangle('Position',[xr,0,300,3*ntrial+2],'FaceColor',[1,1,0,0.3],'EdgeColor','y','Linewidth',1)
   
    ylim([0.5,3*ntrial+1])
    xlim([1,size(rasters{i},1)])
    
    title(namep{i},'FontName','Arial','FontWeight','normal','fontsize',fs)
    
    %{
    if i==2
        text(1.04,0.2,namelay{3},'units','normalized','FontName','Arial','fontsize',fs)
        text(1.04,0.5,namelay{2},'units','normalized','FontName','Arial','fontsize',fs)
        text(1.04,0.8,namelay{1},'units','normalized','FontName','Arial','fontsize',fs)
    end
    %}
    set(gca,'XTick',[200,500,800],'fontsize',fs)
    set(gca,'XTickLabel',xtl(i,:),'fontsize',fs,'FontName','Arial')
    set(gca,'YTick',yt)
    if i==2
        set(gca,'YTickLabel',[])
    else
        set(gca,'YTickLabel',vec,'fontsize',fs,'FontName','Arial')
    end
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
end

axes;

%text(-0.12,1.05,'B', 'units','normalized', 'FontName','Arial','fontsize',fs,'FontWeight','Bold')
% axis labels
h2 = ylabel ('Trial index','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
h1 = xlabel ('Time from stim. onset (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);

% make the global axis invisible
set(gca,'Visible','off');
set(h1,'visible','on')
set(h2,'visible','on')
        
set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'svg');
end


