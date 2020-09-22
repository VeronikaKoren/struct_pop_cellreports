% 

clear all
close all
clc

savefig=1;
period=2;
window=1;

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};


figname=['stpa_info_',namep{period}];
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

orange=[1,0.3,0.05];
gray=[0.2,0.2,0.2];
col={orange,gray};

pos_vec=[0,0,11.4,8];

fs=10;
ms=5;
lw=1.2;
lwa=1;

%% plot coupling of informative and uninformative neurons to the rest of the population

addpath '/home/veronika/synced/struct_result/coupling/1_cond/'
addpath '/home/veronika/synced/struct_result/weights/tag/'

stpa=cell(2,2);
speak=cell(2,2);
pval=zeros(2,1);

nperm=1000;
for ba=1:2
    
    loadname=['stpa_1c_',namea{ba},namep{period},namew{window},'.mat'];                   % load w_svm
    load(loadname)
    
    xall=cell2mat(stpa_all);
    yall=cell2mat(peak);
    
    loadname2=['tag_info_',namea{ba},namep{period},namew{window},'.mat'];
    load(loadname2)
    
    tag_all=cell2mat(tag_info);
    idxi=find(tag_all);
    idxni=find(tag_all==0);
    
    % divide stpa to informative and uninformative neurons
    stpa{ba,1}=xall(idxi,:);
    stpa{ba,2}=xall(idxni,:);
    
    speak{ba,1}=yall(idxi);
    speak{ba,2}=yall(idxni);
    
    N=length(tag_all);
    n1=length(idxi);
    n2=length(idxni);
    
    %% permutation test
    
    p1=zeros(n1,nperm);
    p2=zeros(n2,nperm);
    for p=1:nperm
        
        yperm=yall(randperm(N));                                                % permute neuron indexes for peaks
        p1(:,p)=yperm(1:n1);
        p2(:,p)=yperm(n1+1:end);
      
    end
    
    d=mean(yall(idxi))-mean(yall(idxni));
    d0=mean(p1)-mean(p2);
    
    pval(ba)=sum(d<d0)/nperm;
    
end
%
display(pval,'p-values V1/V4 permutation test');

%%

xvec=-iW+1:iW+1;
msyn=cellfun(@mean,speak);

%[h,p]=ttest2(speak{2,1},speak{2,2},'tail','right');
%% plot

titles={'Coupling function','Peak eCDF','Average peak'};

ymax=0.2;
yt=0:0.08:0.16;
ylimit=[-0.02,ymax];
dx=abs(ylimit(2)-ylimit(1))/18;

idxplt=[1,4];
H=figure('name',figname,'visible','on');

for ba=1:2
    
    y1=stpa{ba,1};
    y2=stpa{ba,2};
    
    z1=speak{ba,1};
    z2=speak{ba,2};
    
    [~,idx1]=max(z1);
    [~,idx2]=max(z2);
    
    subplot(2,3,idxplt(ba))
    hold on
    plot(xvec,y1(idx1,:),'color',col{1},'linewidth',lw+0.5);
    plot(xvec,y2(idx2,:),'color',col{2},'linewidth',lw);
    
    xlim([-50,50])
    ylim(ylimit)
    
    grid on
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt, 'FontName','Arial','Fontsize',fs)
    if ba==1
        title(titles{1}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',[-50,0,50], 'FontName','Arial','Fontsize',fs)
    end
    if ba==2
        xlabel('lag (ms)', 'FontName','Arial','Fontsize',fs)
    end
    
    if ba==1
        text(0.1,0.7,'less info','units','normalized','FontName','Arial','fontsize',fs,'color',gray)
        text(0.1,0.85,'info','units','normalized','FontName','Arial','fontsize',fs,'color',orange)
    end
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [f,x1]=ecdf(speak{ba,1});
    [g,x2]=ecdf(speak{ba,2});
    
    subplot(2,3,idxplt(ba)+1)
    hold on
    plot(x1,f,'color',col{1},'linewidth',lw)
    plot(x2,g,'color',col{2},'linewidth',lw)
    hold off
    
    grid on
    xlim([-0.01,0.2])
    if ba==1
        title(titles{2}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        set(gca,'XTickLabel',[])
    else
        set(gca,'XTickLabel',yt)
    end
    
    if ba==2
        xlabel('coupling at 0 lag', 'FontName','Arial','Fontsize',fs)
    end
    %
    %%
    subplot(2,3,idxplt(ba)+2)
    
    b=bar(msyn(ba,:));
    b.FaceColor = 'flat';
    b.CData(1,:)=col{1};
    b.CData(2,:) = col{2};
    b.FaceAlpha=0.7;
    
    ylim([0,0.1])
    box off
    grid on
    
    maxy=double(max(msyn(ba,:)));
    
    line([1,2],[maxy+dx,maxy+dx],'color','k')
    line([1,1],[maxy+dx,maxy+dx/2],'color','k')
    line([2,2],[maxy+dx,maxy+ dx/2],'color','k')
    
    if pval(ba)<0.05
        text(1.3,maxy+ 1.8*dx,'*','fontsize',fs+3)
    else
        text(1.1,maxy+1.8*dx,'n.s.','fontsize',fs)
    end
     
    set(gca,'YTick',[0.03,0.06])
    set(gca,'YTickLabel',[0.03,0.06],'FontName','Arial','Fontsize',fs)
    
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[]);
    
    
    if ba==1
        title(titles{3}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
    end
    text(1.05,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
end

set(H, 'Units','centimeters', 'Position', pos_vec)
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end

%%

