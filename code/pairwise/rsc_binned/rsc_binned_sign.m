% are noise correlations bigger among neurons with the same selectivity
% compared to neurons with opposite selectivity?
% compute noise correlation between (+/+), (-/-) and (+/-) 
% use both conditions

close all
clear all
clc 
format long

saveres=1;
showfig=1;

ba=2;
period=1;

nperm=1000;

start_vec=[200,500];                                                             % beginning of the time window for the target (200) and the test stimulus (500) 
start=start_vec(period);
K=500;

blv=[20,50,75,100];
bin_length=blv(1);
                                                             
%% load spike counts

namea={'V1','V4'};
namep={'target', 'test'};

addpath('/home/veronika/Dropbox/struct_pop/code/function/')                                         
addpath('/home/veronika/synced/struct_result/input/')
addpath('/home/veronika/synced/struct_result/weights/weights_regular/')

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                   
load(loadname2)
w_vec=cell2mat(cellfun(@(x) double(permute(x,[2,1])),weight_all,'UniformOutput', false));
w_abs=max(abs(w_vec));

%%%%%%%%%%%%%
loadname2=['spike_train_',namea{ba},'_',namep{period}];
load(loadname2);

strain=cellfun(@(x,y) single(cat(1,x,y)),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);  % concatenate conditions
stime=cellfun(@(x) x(:,:,start:start+K-1),strain,'UniformOutput',false);
nbses=length(stime);

%% compute binned spike counts

idx1=1:bin_length:K-bin_length+1;
idx2=bin_length:bin_length:K;
B=length(idx1);

binc=cell(nbses,1);
for ss=1:nbses
    
    vs=stime{ss};
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
    binc{ss}=count_vec;
end

%%

display(['computing rsc in bins within and across coding pools in ', namea{ba}, ' during ', namep{period},' bin=',sprintf('%1.0i',bin_length) ])

rb_minus=cell(nbses,1); 
rb_plus=cell(nbses,1);
across=cell(nbses,1);

pw=cell(nbses,nperm);
pa=cell(nbses,nperm);

for ss=1:nbses                                                                  % across recording sessions
    
    %display(ss)
    
    sc_sess=binc{ss};
    w=weight_all{ss};
    Ntot=length(w);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% regular
    % (-/-)
    %%
    neg=find(w<0);
    sc_use=sc_sess(neg,:);
    N=length(neg);
    Np=(N^2-N)/2;
    rb=zeros(Np,1);
    
    if N>1
        
        counter=0;
        for n=1:N-1
            
            x=sc_use(n,:);
            for m=n+1:N
                
                counter=counter+1;
                y=sc_use(m,:);
                rb(counter)=corr(x',y');
            end
        end
        
    end
    rb_minus{ss}=rb;
    
    %% (+/+)
    pos=find(w>0);
    sc_use=sc_sess(pos,:);
    N=length(pos);
    Np=(N^2-N)/2;
    rb=zeros(Np,1);
    
    if N>1
        
        counter=0;
        for n=1:N-1
            
            x=sc_use(n,:);
            for m=n+1:N
                
                counter=counter+1;
                y=sc_use(m,:);
                rb(counter)=corr(x',y');
            end
        end
        
    end
    rb_plus{ss}=rb;
    
    %% (+/-)
    
    if abs(sum(sign(w)))<length(w)
        sc_use=sc_sess;
        sc1=sc_use(pos,:);
        sc2=sc_use(neg,:);
        Np=length(pos)*length(neg);
        
        rb=zeros(Np,1);
        counter=0;
        for n=1:length(pos)
            x=sc1(n,:);
            for m=1:length(neg)
                counter=counter+1;
                y=sc2(m,:);
                rb(counter)=corr(x',y');
            end
        end
        
        
    end
    
    across{ss}=rb;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% permuted
    %%
    w_nosign=w.*sign(w);
    for p=1:nperm
        
        wrs=sign(- w_abs + (w_abs + w_abs).*rand(Ntot,1)');                    % random sign
        w_perm=w_nosign.*wrs;
        
        neg=find(w_perm<0);
        sc_use=sc_sess(neg,:);
        N=length(neg);
        
        p1=zeros((N^2-N)/2,1);
        
        if N>1
            
            counter=0;
            for n=1:N-1
                
                x=sc_use(n,:);
                for m=n+1:N
                    
                    counter=counter+1;
                    y=sc_use(m,:);
                    p1(counter)=corr(x',y');
                end
            end
            
        end
        
        
        %% (+/+)
        pos=find(w_perm>0);
        sc_use=sc_sess(pos,:);
        N=length(pos);
        p2=zeros((N^2-N)/2,1);
        
        if N>1
            
            counter=0;
            for n=1:N-1
                
                x=sc_use(n,:);
                for m=n+1:N
                    
                    counter=counter+1;
                    y=sc_use(m,:);
                    p2(counter)=corr(x',y');
                end
            end
            
        end
        
        pw{ss,p}=cat(1,p1,p2);
        
        
        %% (+/-)
        sc_use=sc_sess;
        sc1=sc_use(pos,:);
        sc2=sc_use(neg,:);
           
        p3=zeros(length(pos)*length(neg),1);
        if abs(sum(sign(w_perm)))<length(w_perm)
                
            counter=0;
            for n=1:length(pos)
                x=sc1(n,:);
                for m=1:length(neg)
                    counter=counter+1;
                    y=sc2(m,:);
                    p3(counter)=corr(x',y');
                end
            end
            
            
        end
        
        pa{ss,p}=p3;
        
    end
        
           
end
%%
within=cell2mat(cellfun(@(x,y) cat(1,x,y),rb_plus,rb_minus, 'UniformOutput', false));
across=cell2mat(across);
%%

d=nanmean(within) - nanmean(across);

pwp=zeros(nperm,1);
pap=zeros(nperm,1);
for perm=1:nperm
    pap(perm)=nanmean(cell2mat(pa(:,perm)));      % average across neurons
    pwp(perm)=nanmean(cell2mat(pw(:,perm)));
    
end

d0=pap-pwp;
pval=sum(d<d0)/nperm;
display(pval)

%% show fig
if showfig==1
    
    figure()
    hold on
    ecdf(within)
    ecdf(across)
    legend('within','across')
    
end

%% save result

if saveres==1
    address=['/home/veronika/synced/struct_result/pairwise/rb',sprintf('%1.0i',bin_length),'/sign/'];
    filename=['rb_sign',sprintf('%1.0i',bin_length),'_',namea{ba}, '_',namep{period}];
    save([address,filename],'within','across','pwp','pap','pval')
end

%%
