% compute firing rate mean and variance

clear all
close all
clc

saveres=0;
showfig=1;


period=2;
ba=2;
window=3;

nperm=1000;

%%
namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};

start_vec=[500,500,750] - 300*(period==1);                                    % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);

display([start,start+K],'window')

%% load 

addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/tag/')

loadname=['spike_train_',namea{ba},'_',namep{period}];                          
load(loadname)

loadname3=['tag_info_', namea{ba},namep{period},namew{window}];         % load tag informative neurons in the right window
load(loadname3)

%% compute mean and std of spike counts

% use both conditions
strain_all=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))), spiketrain(:,1),spiketrain(:,2),'UniformOutput',false);
nbses=length(strain_all);

dt=1/1000;
sc=cellfun(@(x) squeeze(sum(x,3))./(K*dt),strain_all,'UniformOutput',false); % spike counts in trials

msc=cellfun(@(x) (mean(x))',sc,'UniformOutput',false);                       % spike count, mean across trials           
msc_vec=double(cell2mat(msc));

stdsc=cellfun(@(x) (std(x))',sc,'UniformOutput',false);                       % variance across trials
std_vec=double(cell2mat(stdsc));

%%
idxi=find(cell2mat(tag_info)');
idxn=find(cell2mat(tag_info)==0)';

%% firing rate

msci=cell(2,1);
msci{1}=msc_vec(idxi);
msci{2}=msc_vec(idxn);

ni=cellfun(@length,msci);
N=sum(ni);
% permutation test firing rate

p1=zeros(ni(1),nperm);
p2=zeros(ni(2),nperm);

for perm=1:nperm
    rp=randperm(N);
    msc_ran=msc_vec(rp);
    p1(:,perm)=msc_ran(1:ni(1));
    p2(:,perm)=msc_ran(ni(1)+1:end);
end

d=mean(msci{1})-mean(msci{2});
d0=mean(p1)-mean(p2);

pval_fr=sum(d<d0)/nperm;

%% standard deviation of spike counts

stdi=cell(2,1);
stdi{1}=std_vec(idxi);
stdi{2}=std_vec(idxn);

p1=zeros(ni(1),nperm);
p2=zeros(ni(2),nperm);

for perm=1:nperm
    rp=randperm(N);
    ran=std_vec(rp);
    p1(:,perm)=ran(1:ni(1));
    p2(:,perm)=ran(ni(1)+1:end);
end

d=mean(stdi{1})-mean(stdi{2});
d0=mean(p1)-mean(p2);

pval_std=sum(d<d0)/nperm;

%%

display(pval_fr,'p-val perm test fr')
display(pval_std,'p-val perm test std')

%%

if showfig==1
    figure()
    subplot(2,1,1)
    title('mean')
    hold on
    ecdf(msci{1})
    ecdf(msci{2})
    
    subplot(2,1,2)
    title('standard deviation')
    hold on
    ecdf(stdi{1})
    ecdf(stdi{2})
    
end

%% save results

if saveres==1
    address='/home/veronika/synced/struct_result/stats/';
    filename=['stats_info_',namea{ba},namep{period},namew{window}];
    save([address, filename],'msci','stdi','pval_fr','pval_std')
end

%%
%{

%%
fr=cell(2,2);
frp=cell(2,2);

sigma=cell(2,2);
sigmap=cell(2,2);


for ba=1:2
    
    loadname0=['w_info_',namea{ba},namep{period},'.mat'];                   % load w_svm
    load(loadname0)
    
    idx1=cat(1,idx_h,idx_l);
    idx2=idx_m;
    Ntot=length(idx1)+length(idx2);
    n1=length(idx1);
    n2=length(idx2);
    
    %% mean firing rate
    
    loadname1=['sc_',namea{ba},'.mat'];                                           
    load(loadname1);
    if period==1
        sc=sc_tar;
    else
        sc=sc_test;
    end
    
    firing_rate=cellfun(@(x,y) single(mean(cat(1,x,y))./(K./1000)), sc(1,:), sc(2,:),'UniformOutput', false)'; %mean firing rate across trials
    frmat=cell2mat(cellfun(@(x) permute(x,[2,1]), firing_rate,'UniformOutput', false));
    fr{ba,1}=frmat(idx1);
    fr{ba,2}=frmat(idx2);
    
    % permuted neuron index
    variable=zeros(nperm,Ntot);
    for p=1:nperm
        variable(p,:)=frmat(randperm(Ntot));
    end
    
    frp{ba,1}=variable(:,1:n1)';
    frp{ba,2}=variable(:,n1+1:end)';
    
    
    %% variance of spike counts
    
    stda=cellfun(@(x,y) single(std(cat(1,x,y))), sc(1,:),sc(2,:),'UniformOutput', false)';
    sigma_mat=cell2mat(cellfun(@(x) permute(x,[2,1]), stda,'UniformOutput', false));
    sigma{ba,1}=sigma_mat(idx1);
    sigma{ba,2}=sigma_mat(idx2);
    
    variable=zeros(nperm,Ntot);
    for p=1:nperm
        variable(p,:)=sigma_mat(randperm(Ntot));
    end
    
    sigmap{ba,1}=variable(:,1:n1)';
    sigmap{ba,2}=variable(:,n1+1:end)';
    
    %% get S-MUA
    
    loadname2=['smua_1c_',namea{ba},'_',namep{period},'.mat'];               % load smua 1c         
    load(loadname2)
    smua_max=max(smua_cat)';                                                 % peak of the S_MUA
    
    smua{ba,1}=smua_max(idx1);
    smua{ba,2}=smua_max(idx2);
    
    variable=zeros(nperm,Ntot);
    for p=1:nperm
        variable(p,:)=smua_max(randperm(Ntot));
    end
    
    smuap{ba,1}=variable(:,1:n1)';
    smuap{ba,2}=variable(:,n1+1:end)';
    
    
end

%% test the hypothesis: informative neurons have stronger firing rate, bigger variance and stronger coupling to the population
pval=zeros(2,3);
for ba=1:2
    
    d=mean(fr{ba,1})-mean(fr{ba,2});
    d0=cellfun(@(x,y) mean(x)-mean(y),frp(ba,1),frp(ba,2),'UniformOutput',false);
    pval(ba,1)=sum(d<d0{:})./nperm;
    
    d=mean(sigma{ba,1})-mean(sigma{ba,2});
    d0=cellfun(@(x,y) mean(x)-mean(y),sigmap(ba,1),sigmap(ba,2),'UniformOutput',false);
    pval(ba,2)=sum(d<d0{:})./nperm;
    
    d=mean(smua{ba,1})-mean(smua{ba,2});
    d0=cellfun(@(x,y) mean(x)-mean(y),smuap(ba,1),smuap(ba,2),'UniformOutput',false);
    pval(ba,3)=sum(d<d0{:})./nperm;
     
end

display(pval)

%%

bbx=cell(3,2,2);
bbx(1,:,:)=fr;
bbx(2,:,:)=sigma;
bbx(3,:,:)=smua;


col={orange,gray};
yts=[0:30:60;0:5:10;0:0.15:0.3];
yl=yts(:,end)+yts(:,end).*0.07;

titles={'F.rate','STD','Coupling to all'};

H=figure('name',figname,'visible','on');
for c=1:3
    for ba=1:2
        
        x=mean(bbx{c,ba,1});
        y=mean(bbx{c,ba,2});
        
        [f,xvec]=ksdensity(x);
        g=ksdensity(y,xvec);
        
        subplot(2,3,c+(ba-1)*3)
        b=bar([x,y]);
        b.FaceColor = 'flat';
        b.CData(1,:)=col{1};
        b.CData(2,:) = col{2};
        b.FaceAlpha=0.7;
        
        %maxy=double(max([x,y]));
        maxy=yl(c);
        line([1,2],[maxy+maxy*0.1,maxy+maxy*0.1],'color','k')
        line([1,1],[maxy+maxy*0.1,maxy+maxy*0.05],'color','k')
        line([2,2],[maxy+maxy*0.1,maxy+maxy*0.05],'color','k')
        if pval(ba,c)<0.05
            text(1.4,maxy+0.15*maxy,'*','fontsize',fs+3)
        else
            text(1.2,maxy+0.2*maxy,'n.s.','fontsize',fs)
        end
        
        ylim([0,maxy+0.35*maxy])
        if ba==1
            title(titles{c}, 'FontName','Arial','Fontsize',fs,'Fontweight','normal')
        end
        if c==3
            text(1.05,0.5,namea{ba},'units','normalized','FontWeight','normal','FontName','Arial','fontsize',fs)
        end
        set(gca,'YTick',yts(c,:), 'FontName','Arial','Fontsize',fs)
        set(gca,'XTick',[1,2])
        hs=set(gca,'XTickLabel',{'info', 'not info'});
        xtickangle(35)
        box off
        
        set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    end
end

axes;
text(-0.08,1.05,letter{period}, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold')    
h2 = ylabel ('Coefficient','units','normalized','Position',[-0.07,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','off')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
%}
%%
%{
figure()

for c=1:3
    for ba=1:2
        x=bbx{c,ba,1};
        y=bbx{c,ba,2};
        
        subplot(2,3,c+(ba-1)*3)
        hold on
        ecdf(x)
        ecdf(y)
        
    end
end
%}