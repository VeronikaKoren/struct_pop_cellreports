% illustrate the method for computing the area under ROC curve (auc score) in single neurons
% find the index of the neurons with strongest auc score
% load spike counts for this neuron
% show the computation of the AUC step-by-step: 
%(1)estimate the probability density
% (2) compute the cumulative distribution function
% (3) compute the area undr the ROC curve

clear all
close all
clc

savefig=0;

ba=2;
period=2;

nperm=1000;

task='illustrate the method of the area under the ROC curve';
disp(task)

savefile='/home/veronika/Dropbox/struct_pop/figure/weights/';
figname='auc_method';

%%
letter='B';
namea={'V1','V4'};
namep={'target','test'};

pos_vec=[0,0,6,9.5];
fs=10;
ms=6;
lw=1.2;
lwa=1;
%% load results

% take the index of the neuron with highest auc score

addpath('/home/veronika/struct_pop/result/classification/auc_regular/')
addpath('/home/veronika/struct_pop/result/input/spike_count/')


% find cell with highest auc score
loadname=['auc_',namea{ba},namep{period},'.mat'];
load(loadname,'auc');

[~,sidx]=max(cellfun(@(x) max(x),auc));
[~,nidx]=max(auc{sidx});

%% load spike counts and compute roc curve and AUC for one neurons

loadname=['sc_',namea{ba},'.mat'];
load(loadname);

if period==1
    sc_all=sc_tar;
else
    sc_all=sc_test;
end


xvec=linspace(0,100,200); % support
        
%%%%%%%% compute AUC score %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data1=sc_all{1,sidx}(:,nidx); % spike counts condition 1 for the chosen neuron
data2=sc_all{2,sidx}(:,nidx); % spike counts condition 2 for the chosen neuron

% estimate average bandwidth
[~,~,u1]=ksdensity(data1(:),xvec);
[~,~,u2]=ksdensity(data2(:),xvec);
bw=mean([u1,u2]);

% get probability distribution
g1=ksdensity(data1,xvec,'bandwidth',bw);
g2=ksdensity(data2,xvec,'bandwidth',bw);

g1norm=g1./sum(g1); % normalize distribution
g2norm=g2./sum(g2);

% cumulative distrubution function
r1=cumsum([0,g1norm]);
r2=cumsum([0,g2norm]);

% compute the auc score (area under the ROC curve)
auc=trapz(r2,r1); 

%% compute distribution of AUC scores with permuted class labels

a_perm=zeros(1,nperm);
g1_perm=zeros(nperm,length(xvec));
g2_perm=zeros(nperm,length(xvec));

r1_perm=zeros(nperm,length(xvec)+1);
r2_perm=zeros(nperm,length(xvec)+1);

n1=length(data1);
n2=length(data2);
%%
merged=[data1;data2]; % concatenate 2 distributions

for pp=1:nperm 
    rp=randperm(n1+n2);                                                        % permutations
    d1=ksdensity(merged(rp(1:n1)),xvec,'bandwidth',bw);
    d2=ksdensity(merged(rp(n1+1:end)),xvec,'bandwidth',bw);
    
    g1_perm(pp,:)=d1./sum(d1);
    g2_perm(pp,:)=d2./sum(d2);
    
    r1_perm(pp,:)=cumsum([0,g1_perm(pp,:)]);
    r2_perm(pp,:)=cumsum([0,g2_perm(pp,:)]);
    
    a_perm(1,pp)=trapz(r2_perm(pp,:),r1_perm(pp,:));
    
end

%% plot distributions, roc curves and auc score
savefig=1;

H=figure('name',figname);

subplot(2,1,1)
hold on
plot(xvec, g1_perm','color',[0.5,0.5,0.5])
plot(xvec, g2_perm','color',[0.5,0.5,0.5])
plot(xvec, g1,'color','r','linewidth',lw+1)
plot(xvec, g2,'color','k','linewidth',lw+1)
hold off
xlim([0,80])
ylim([0,0.055])
% write legend
text(0.3,0.9,'non-match','color','red','units','normalized','Fontsize',fs,'FontName','Arial')
text(0.4,0.8,'match','color','k','units','normalized','Fontsize',fs,'FontName','Arial')
xlabel('Spike count','Fontsize',fs,'FontName','Arial')
ylabel('Density','units','normalized','Position',[-0.15,0.5,0],'Fontsize',fs,'FontName','Arial')

set(gca,'XTick',[0,50])
set(gca,'XTickLabel',[0, 50],'Fontsize',fs,'FontName','Arial')
set(gca,'YTick',0.05)
set(gca,'YTickLabel',0.05,'Fontsize',fs,'FontName','Arial')
set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);

box off
%text(-0.3,1.12,'A', 'units','normalized', 'FontName','Arial','fontsize',fs,'FontWeight','Bold')
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2,1,2)
hold on
for p=1:100
    plot(r2_perm(p,:),r1_perm(p,:),'color',[0.5,0.5,0.5])
end
plot(r2,r1,'k','linewidth',lw+1)

% average over permuted
plot(mean(r1_perm,1),mean(r2_perm,1),'--b','linewidth',lw)

% write AUC in two lines
text(0.07,0.85,'AUROC','units','normalized','Fontsize',fs,'FontName','Arial')
text(0.07,0.72,[' = ' sprintf('%0.2f',auc)],'units','normalized','Fontsize',fs,'FontName','Arial')
text(0.55,0.3,'\langle AUROC \rangle_{p}','units','normalized','Fontsize',fs,'FontName','Arial','color','b')
text(0.55,0.17,['  = ' sprintf('%0.2f',mean(a_perm))],'units','normalized','Fontsize',fs,'FontName','Arial','color','b')

set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
box off
axis([0,1,0,1])
xlabel('cdf match','Fontsize',fs,'FontName','Arial')
ylabel('cdf non-match','Fontsize',fs,'FontName','Arial')
set(gca,'XTick',0:0.5:1)
set(gca,'XTickLabel',0:0.5:1,'Fontsize',fs,'FontName','Arial')
set(gca,'YTick',[0.5,1])
set(gca,'YTickLabel',[0.5,1],'Fontsize',fs,'FontName','Arial')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axes
%h0=text(-0.13,1.05,letter, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold'); 
set(gca,'Visible','off')
set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

