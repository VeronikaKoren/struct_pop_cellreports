% correlations of binned spike trains for informative and less informative
% neurons

close all
clear all
clc 
format long

saveres=1;
showfig=1;

ba=2;
period=1;

nperm=1000;

start_vec=[200,500];                                   % onset for the target (200) and the test stimulus (500) 
start=start_vec(period);
K=500;

blv=[20,50,75,100];
bin_length=blv(4);
       
%% load spike counts

namea={'V1','V4'};
namep={'target', 'test'};
%namec={'nm','m'};

addpath('/home/veronika/Dropbox/struct_pop/code/function/')                            
addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/tag/')

loadname=['tag_info_',namea{ba},namep{period}];
load(loadname);

loadname2=['spike_train_',namea{ba},'_',namep{period}];
load(loadname2);

strain=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);
nbses=length(strain);

%% compute binned spike counts
tic

idx1=1:bin_length:K-bin_length+1;
idx2=bin_length:bin_length:K;
B=length(idx1);

binc=cell(nbses,1);
for sess=1:nbses
    
    vs=strain{sess};
    J=size(vs,1);
    N=size(vs,2);
    
    count_vec=zeros(N,J*B);
    for n=1:N
        count=zeros(size(vs,1),length(idx1));
        for j=1:J
            for b=1:B     
                count(j,b)=sum(vs(j,n,idx1(b):idx2(b)));
            end
        end
        count_norm=(count-repmat(nanmean(count),J,1))./repmat(nanstd(count),J,1);   % z-score every bin
        
        count_vec(n,:)=count_norm(:);
    end
    binc{sess}=count_vec;
end

%%

display(['computing rsc in bins for info and not info in ', namea{ba}, ' ', namep{period}])

infoc=cell(nbses,1); 
notinfoc=cell(nbses,1);

nipc=cell(nbses,1);
ipc=cell(nbses,1);

parfor sess=1:nbses                                                    % across recording sessions
    
    bin_sess=binc{sess};
    N=size(bin_sess,1); 
    
    % informative
    idx_i=find(tag_info{sess});
    n1=length(idx_i);
    np1=(n1^2-n1)/2;
    
    input=bin_sess(idx_i,:);
    r=zeros(np1,1);
    counter=0;
    for n=1:n1-1
        
        x=input(n,:);
        for m=n+1:n1
            
            counter=counter+1;
            y=input(m,:);
            r(counter)=corr(x',y');
        end
    end
    infoc{sess}=r;
    
    % not informative
    idx_ni=find(tag_info{sess}==0);
    n2=length(idx_ni);
    np2=(n2^2-n2)/2;
    
    input=bin_sess(idx_ni,:);
    r=zeros(np2,1);
    counter=0;
    for n=1:n2-1
        
        x=input(n,:);
        for m=n+1:n2
            
            counter=counter+1;
            y=input(m,:);
            r(counter)=corr(x',y');
        end
    end
    notinfoc{sess}=r;
    
    %%%%%%%%%%%%%%%% permuted model
    %%
    n1=round(N/2);
    n2=N-n1;
    np1=(n1^2-n1)/2;
    np2=(n2^2-n2)/2;
    rpi=zeros(np1,nperm);
    rpn=zeros(np2,nperm);
    for p=1:nperm
        
        permn=randperm(N);
        
        % group 1
        idx_i=permn(1:n1);
        input=bin_sess(idx_i,:);
        counter=0;
        for n=1:n1-1
            
            x=input(n,:);
            for m=n+1:n1
                
                counter=counter+1;
                y=input(m,:);
                rpi(counter,p)=corr(x',y');
            end
        end
        
        % group 2
        idx_ni=permn(n1+1:end);
        input=bin_sess(idx_ni,:);
        
        counter=0;
        for n=1:n2-1
            
            x=input(n,:);
            for m=n+1:n2
                
                counter=counter+1;
                y=input(m,:);
                rpn(counter,p)=corr(x',y');
            end
        end
       
    end
    
    ipc{sess}=rpi;
    nipc{sess}=rpn;
    
 
end

toc

%% permutation test

info=cell2mat(infoc);
notinfo=cell2mat(notinfoc);

ip=cell2mat(ipc);
nip=cell2mat(nipc);

d=nanmean(info)-nanmean(notinfo);
d0=nanmean(ip)-nanmean(nip);

pval=sum(d<d0)/nperm;
display(pval,'p-value permutation test')

%% show fig

if showfig==1
    figure('units','centimeters','Position',[0,0,36,12])
    subplot(1,2,1)
    hold on
    ecdf(info)
    ecdf(notinfo)
    legend('info','not info')
    [h,p_ttest]=ttest2(info, notinfo,'tail','right');
    display(p_ttest)
    
    subplot(1,2,2)
    
    hold on
    boxplot(d0)
    plot(d,'kx','linewidth',3)
    ylim([-0.05,0.08])
    text(0.1,0.8,['pval=', sprintf('%0.4f',pval)],'units','normalized')
    
end

%% save result

if saveres==1
    address=['/home/veronika/synced/struct_result/pairwise/rb',sprintf('%1.0i',bin_length),'/info/'];
    filename=['r_info_',namea{ba},namep{period}];
    save([address,filename],'info','notinfo','ip','nip','pval')
end

%%
