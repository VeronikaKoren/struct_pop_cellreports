%% 
clear all
close all
format long

saveres=0;
period=2;

%%
namea={'V1','V4'};
namep={'target','test'};

bv=[0.5,0]; % baseline

%% load results

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
addpath('/home/veronika/synced/struct_result/weights/weights_permuted/')

%%

w=cell(2,1);        % {area} (Ntot);
wp=cell(2,1);       % {area} (Ntot,nperm);

for ba=1:2
    
    loadname=['svmw_',namea{ba},namep{period},'.mat'];
    load(loadname);
    w{ba}=cell2mat(cellfun(@(x) single(permute(x,[2,1])),weight_all,'UniformOutput',false));
    
    loadname2=['svmw_perm_',namea{ba},namep{period},'.mat'];
    load(loadname2)
    wp{ba}=cell2mat(weight_perm_all);
     
end

nperm=size(wp{1,1},2);

%% 95 percent of permuted statistics 

pr=cell(2,1);
pl=cell(2,1);

lb=cell(2,1);
ub=cell(2,1);

hyp=cell(2,1);

for ba=1:2
    
    x=w{ba};
    xp=wp{ba};
    
    nc=length(x);
    alpha=0.05./nc;
    
    idx=round(alpha*nperm)+1;
    
    lower_bound=zeros(nc,1);
    upper_bound=zeros(nc,1);
    p_right=zeros(nc,1);
    p_left=zeros(nc,1);
    h=zeros(nc,1);
    
    for i=1:nc
        
        sorted=sort(xp(i,:));
        lower_bound(i)=sorted(idx);
        upper_bound(i)=sorted(nperm-(idx));
        
        if x(i)<lower_bound(i)
            h(i)=1;
        elseif x(i)>upper_bound(i)
            
            h(i)=1;
        end
        
        p_right(i)=sum(x(i,1)<xp(i,:))/nperm;
        p_left(i)=sum(x(i,1)>xp(i,:))/nperm;
        
    end
    
    pr{ba}=p_right;
    pl{ba}=p_left;
    hyp{ba}=h;
    
    lb{ba}=lower_bound;
    ub{ba}=upper_bound;
    
end

%%
if saveres==1
    
    savename=['tag_significant_',namep{period}];
    savefile='/home/veronika/synced/struct_result/weights/tag/';    
    save([savefile,savename],'hyp','lb','ub','pr','pl')
    
end
