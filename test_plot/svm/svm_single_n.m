% tests and plots the performance of the svm on the difference of spike
% counts and the performance of the average single neuron
% in V1 and V3
% test significance with the permutation test

clear all
close all
clc
format long

savefig=1;
period=1;

alpha=0.05; % significance level

namea={'V1','V4'};
namep={'target','test'};
letter={'B','B'};

figname=['hdim_singlen_',namep{period}];
if period==1
    savefile='/home/veronika/Dropbox/struct_pop/figure/S1:svm_target/';
else
    savefile='/home/veronika/Dropbox/struct_pop/figure/hdim_singlen/';
end

pos_vec=[0,0,12,9]; % size of the figure in cm
lw=1.0;
ms=6;
fs=10;
lwa=1;
green=[0.2,0.7,0];

%% load classification results

addpath('/home/veronika/struct_pop/result/classification/svm_tartest/hdim/')
addpath('/home/veronika/struct_pop/result/classification/svm_tartest/singlen/')

acc=cell(2,1); % {area} (nbses);
acc_perm=cell(2,1); % {area} (enbses,nperm);
acc_singlen=cell(2,1); % {area} (nbses);

for ba=1:2
    
    loadname=['svm_',namea{ba},namep{period},'.mat'];
    load(loadname);
   
    
    acc{ba}=bac_all;        % balanced accuracy
    acc_perm{ba}=bac_allp;  % belenced accuracy with permuted class labels
         
    clear bac_all
    loadname=['svm_singlen_',namea{ba},namep{period},'.mat'];
    load(loadname);
   
    acc_singlen{ba}=cellfun(@mean, bac_all);
end

%% permutation test on the p-value

mean_acc=cellfun(@(x) squeeze(mean(x)), acc);                                   % mean across sessions
mean_accp=cellfun(@(x) squeeze(mean(x)),acc_perm,'UniformOutput',false);
mean_single=cellfun(@mean, acc_singlen);

p_mean=zeros(2,1);
for ba=1:2
    
    x=mean_acc(ba);
    x0=mean_accp{ba};
    p_mean(ba)= sum(x0>x)/length(x0);
    
end

h_mean=p_mean< alpha/numel(p_mean);
display(p_mean,'p-val SVM high-dimensional')

%% pairwise test population vs single neurons

p_sess=zeros(2,1);
for ba=1:2
    p_sess(ba)=signrank(acc{ba},acc_singlen{ba});
end
display(p_sess, 'p-val pop vs singlen')


%% plot balanced accuracy: session mean and individual sessions

col={'k','m'};

H=figure('name',figname,'visible','on');

idxp=[[1,2];[4,5]];
if period==1
    yt=0.4:0.1:0.6; % y tick
else
    yt=0.5:0.1:0.7;
end

xt=[1,7,14;1,4,8];

for ba=1:2
    
    subplot(2,3,idxp(ba,:))
    x1=acc{ba,1};
    x2=acc_singlen{ba};
    
    [val,order]=sort(x1);
    new_order=flip(order);
    x1=x1(new_order);
    x2=x2(new_order);
    
    subplot(2,3,idxp(ba,:))
    hold on
    plot(x1,'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(x2,'x','color',col{2},'markersize',ms,'Linewidth',lw+1);
    
    plot(0:length(x1)+1,ones(length(x1)+2,1).*0.5,'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw-0.5)
    hold off
    if period==1
        axis([0,length(x1)+1,0.4,0.6])
    else
        axis([0,length(x1)+1,0.4,0.8])
    end
    box off
    grid on
    
    if ba==1
        text(0.3,0.89,'population','units','normalized','FontName','Arial','fontsize',fs,'color',col{1})
        text(0.3,0.79,'average single neuron','units','normalized','FontName','Arial','fontsize',fs,'color',col{2})
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt,'fontsize',fs)
    if ba==2
        xlabel ('Session index','FontName','Arial','fontsize',fs);
    end
   
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
       
end

bars=[mean_acc,mean_single];
if period==1
    ylimit=[0.49,0.55];
else
    ylimit=[0.5,0.62];
end
dx=0.005;

for ba=1:2
    
    subplot(2,3,ba*3)
    hold on
    if period==1
        line([0,3],[0.5,0.5],'color',[0.5,0.5,0.5],'linestyle','--')
    end
    bar(1,bars(ba,1),'FaceColor',[0.2,0.2,0.2],'EdgeColor','k','linewidth',2);
    bar(2,bars(ba,2),'FaceColor',col{2},'EdgeColor',col{2},'linewidth',2);
    
    hold off
     
    % draw significance lines
    xb=max(bars(ba,:))+4*dx;
    line([1,2],[xb, xb],'color','k')
    line([1,1],[xb-dx,xb])
    line([2,2],[xb-dx,xb])
    
    if p_sess(ba)<alpha
        th=text(1.4,xb+dx,'*','color','r','fontsize',fs+7);
    else
        th=text(1.2,xb+dx*1.5,'n.s.','color','k','fontsize',fs);
    end
    set(gca,'XTick',[1,2])
    set(gca,'XTickLabel',[])
    if ba==2
        set(gca,'XTickLabel',{'population','single n.'},'XTickLabelRotation',40)
    end
   
    ylim(ylimit)
    xlim([0,3])
    box off
    if period==2
        set(gca,'YTick',[0.5,0.55])
    else
        set(gca,'YTick',[0.5,0.52])
    end
    text(1.05,0.5,namea{ba},'units','normalized')
end

axes

h0=text(-0.15,1.05,letter{period}, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold'); 
h2 = ylabel ('Balanced accuracy','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs); 
set(gca,'Visible','off')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

%%
%{
acc_sign=cell(2,1); % {area} (nbses,sign);
accp_sign=cell(2,1); % {area} 

for ba=1:2
    
    loadname=['svm_sign_',namea{ba},'.mat'];
    load(loadname);
     
    acc_sign{ba}=bac_sign;
    accp_sign{ba}= bac_signp;
    
end

sm=cellfun(@(x) nanmean(x),acc_sign,'UniformOutput',false);                % average across sessions
smp=cellfun(@(x) squeeze(nanmean(x)),accp_sign,'UniformOutput',false);

%% test with permutation test

nperm=size(smp{1},1);
pval_sign=zeros(2,2);
for ba=1:2
    for sn=1:2
        x=sm{ba}(sn);
        x0=smp{ba}(:,sn);
        pval_sign(ba,sn)=sum(x<x0)./nperm;
    end
end
hyp_sign=pval_sign<(0.05/numel(pval_sign));

%% test difference between plus and minus in the same area

pval_diff=ones(2,1);
for ba=1:2
    
    x=abs(sm{ba}(2)-sm{ba}(1));
    x0=smp{ba}(:,2)-smp{ba}(:,1);
    pval_diff(ba)=sum(x<x0)./nperm;
    
end
hyp_diff=pval_diff<(0.05/numel(pval_diff));
%}
