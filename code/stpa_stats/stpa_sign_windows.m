% computes spike-triggered population activity (S-MUA) within and across
% coding pools in first and second part of the trial

close all
clear all
clc 
format long

place=1;
saveres=0;
showfig=1;

period=2;

ba=1;
window=3;

nbit=5;
nperm=3;

%% window
start_vec=[500,500,750] - 300*(period==1);                                    % beginning of the time window 
start=start_vec(window);
Kvec=[500,250,250];
K=Kvec(window);

display([start,start+K])
%% 

iW=50; % maximal lag

namea={'V1','V4'};
namep={'target', 'test'};
namew={'','first_half_','second_half_'};

if place==1
    addpath('/home/veronika/Dropbox/struct_pop/code/function/')                    
else
    addpath('/home/veronika/struct_pop/code/function/')
end

disp(['spike-triggered pop sign ',namea{ba}, ' ', namew{window}])

%% load spike counts                                                                         

addpath('/home/veronika/synced/struct_result/weights/weights_regular/');
addpath('/home/veronika/synced/struct_result/input/');
addpath('/home/veronika/Dropbox/struct_pop/code/function/')

loadname=['spike_train_',namea{ba},'_',namep{period}];
load(loadname);

strain_all=cellfun(@(x,y) single(cat(1,x(:,:,start:start+K-1),y(:,:,start:start+K-1))),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);

%% load weights

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
loadname=['svmw_',namew{window},namea{ba},namep{period},'.mat'];                   
load(loadname)
w_vec=cell2mat(cellfun(@(x) permute(x,[2,1]),weight_all,'UniformOutput', false));
w_abs=max(abs(w_vec));

nbses=size(weight_all,1);

%%
tic
stp_minus=cell(nbses,1); 
stp_plus=cell(nbses,1);
min2plus=cell(nbses,1);
plus2min=cell(nbses,1);

pw=cell(nbses,nperm);
pa=cell(nbses,nperm);

for ss=1:nbses                                                                  % across recording sessions
    
    %display(ss)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% regular
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%5
    w=weight_all{ss};
    N=length(w);
    
    % (-/-)
    neg=find(w<0);
    if length(neg)>1
        
        s_train=strain_all{ss}(:,neg,:);
        [smua] = smua_fun(s_train,nbit,iW);
        stp_minus{ss}=smua';
    end
    
    % (+/+)
    
    pos=find(w>0);
    if length(pos)>1
        
        s_train=strain_all{ss}(:,pos,:);
        [smua] = smua_fun(s_train,nbit,iW);
        stp_plus{ss}=smua';
    end
    
    % (+/-)
   
    if min([length(pos),length(neg)])>1                                         % at least two neurons in each group
        s_train=strain_all{ss};
        [smua_sgn] = smua_sign_fun(w,s_train,nbit,iW);
        
        min2plus{ss}=smua_sgn{1}';
        plus2min{ss}=smua_sgn{2}';
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% regular
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%
    %%
    w_nosign=w.*sign(w);                                                    % all positive
    
    for perm=1:nperm
        wrs=sign(- w_abs + (w_abs + w_abs).*rand(N,1)');                    % random sign
        w_perm=w.*wrs;                                                      % apply random sign
        
        % (-/-)
        neg=find(w_perm<0);
        peak1=[];
        if length(neg)>1
            
            s_train=strain_all{ss}(:,neg,:);
            [smua] = smua_fun(s_train,nbit,iW);
            peak1=smua(iW,:);
        end
        
        % (+/+)
        
        pos=find(w_perm>0);
        peak2=[];
        if length(pos)>1
            
            s_train=strain_all{ss}(:,pos,:);
            [smua] = smua_fun(s_train,nbit,iW);
            peak2=smua(iW,:);
        end
        pw{ss,perm}=cat(2,peak1,peak2)';
        
        % (+/-)
        
        if min([length(pos),length(neg)])>1                                         % at least two neurons in each group
            s_train=strain_all{ss};
            [smua_sgn] = smua_sign_fun(w_perm,s_train,nbit,iW);
            
            pa{ss,perm}=cat(2,smua_sgn{1}(iW,:),smua_sgn{2}(iW,:))';
            
            
        end
       
    end
      
end

toc

%%

stp_within=cell2mat(cellfun(@(x,y) cat(1,x,y),stp_plus,stp_minus,'UniformOutput', false));
stp_across=cell2mat(cellfun(@(x,y) cat(1,single(x),single(y)),min2plus,plus2min,'UniformOutput', false));
d=mean(stp_within(:,iW))-mean(stp_across(:,iW));

%%
pa=cellfun(@single, pa,'UniformOutput',false);

pwp=zeros(nperm,1);
pap=zeros(nperm,1);
for perm=1:nperm
    pap(perm)=mean(cell2mat(pa(:,perm)));      % average across neurons
    pwp(perm)=mean(cell2mat(pw(:,perm)));
    
end

d0=pap-pwp;

pval=sum(d<d0)/nperm;
display(pval,'permutation test SMUA within pools > SMUA across pools')

%%

if showfig==1
    figure()
    hold on
    plot(mean(stp_within))
    plot(mean(stp_across))
    legend('within','across')
end

%% save result

if saveres==1
    address='/home/veronika/synced/struct_result/coupling/sign/';
    filename=['stp_sign_',namew{window},namea{ba}, '_',namep{period}];
    save([address,filename],'stp_within','stp_across','pa','pw','pval','iW')
end

%%
