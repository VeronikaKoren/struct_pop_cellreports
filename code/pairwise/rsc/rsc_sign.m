% are noise correlations bigger within neurons with the same selectivity
% compared to neurons with opposite selectivity?
% compute noise correlation between (+/+), (-/-) and (+/-) 
% use both conditions

close all
clear all
clc 
format long

saveres=1;
showfig=1;

ba=1;
period=2;

nperm=1000;
K=500;                                                                          % number of time steps

start_vec=[200,500];                                                             % beginning of the time window for the target (200) and the test stimulus (500) 
start=start_vec(period);
display([start,start+K],'window')
%% load spike counts

namea={'V1','V4'};
namep={'target', 'test'};

addpath('/home/veronika/Dropbox/struct_pop/code/function/')                    % load spike counts
addpath('/home/veronika/synced/struct_result/input/')


loadname=['spike_train_',namea{ba},'_',namep{period}];
load(loadname);

strain=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);
sc_all=cellfun(@(x) squeeze(sum(x,3)) ,strain, 'UniformOutput',false);

nbses=size(sc_all,1);

%% load weights

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')

loadname2=['svmw_',namea{ba},namep{period},'.mat'];                    
load(loadname2)

w_vec=cell2mat(cellfun(@(x) double(permute(x,[2,1])),weight_all,'UniformOutput', false));
w_abs=max(abs(w_vec));

%%

display(['computing rsc within and across coding pools in ', namea{ba}, ' during ', namep{period}])

rsc_minus=[]; 
rsc_plus=[];
across=[];

pw=cell(nbses,nperm);
pa=cell(nbses,nperm);

tic

for ss=1:nbses                                                                  % across recording sessions
    
    %display(ss)
    sc_sess=sc_all{ss};
    w=weight_all{ss};
    N=length(w);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % (-/-)
    neg=find(w<0);
    input=sc_sess(:,neg);
    [ r] = noise_correlation_sc_fun(input);
    rsc_minus=cat(1,rsc_minus,r);
    
    % (+/+)
    pos=find(w>0);
    input=sc_sess(:,pos);
    [ r] = noise_correlation_sc_fun( input);
    rsc_plus=cat(1,rsc_plus,r);
    
    %% (+/-)
    input=sc_sess;
    [ r] = noise_correlation_sign_fun(input,w);
    across=cat(1,across,r);
    
    %%%%%%%%%%%%%%%%%%%%%% permuted
    %%
    w_nosign=w.*sign(w);
    
    for p=1:nperm
        
        wrs=sign(- w_abs + (w_abs + w_abs).*rand(N,1)');                    % random sign
        w_perm=w_nosign.*wrs;
        
        % (-/-)
        neg=find(w_perm<0);
        input=sc_sess(:,neg);
        p1 = noise_correlation_sc_fun(input);
        
        % (+/+)
        pos=find(w_perm>0);
        input=sc_sess(:,pos);
        p2 = noise_correlation_sc_fun( input);
        
        pw{ss,p}=cat(1,p1,p2);
        
        %% (+/-)
        input=sc_sess;
        pa{ss,p} = noise_correlation_sign_fun(input,w_perm);
        
        
    end
end

toc
%%
within=cat(1,rsc_plus,rsc_minus);

if showfig==1
    
    figure()
    hold on
    ecdf(within)
    ecdf(across)
    legend('within','across')
    
end

%%
d=mean(within)-mean(across);

pwp=zeros(nperm,1);
pap=zeros(nperm,1);
for perm=1:nperm
    pap(perm)=mean(cell2mat(pa(:,perm)));      % average across neurons
    pwp(perm)=mean(cell2mat(pw(:,perm)));
    
end

d0=pap-pwp;
pval=sum(d<d0)/nperm;
display(pval)

%% save result

if saveres==1
    address='/home/veronika/synced/struct_result/pairwise/rsc/sign/';
    filename=['rsc_sign_',namea{ba}, '_',namep{period}];
    save([address,filename],'within','across','pwp','pap','pval')
end

%%
