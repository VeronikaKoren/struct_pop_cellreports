% correlation of best single neurons and AURIC scores 

clear all
close all
clc
format long

savefig=0;
period=2;

alpha=0.05;                 % significance threshold

%%
namea={'V1','V4'};
namep={'target','test'};

%

addpath('/home/veronika/synced/struct_result/weights/weights_regular/')
addpath('/home/veronika/synced/struct_result/classification/auc_regular/')

nperm=1000;
%%


overlap=cell(2,1);
wsvm_max=cell(2,1);
wauc_max=cell(2,1);
for ba=1:2
   
    loadname=['svmw_',namea{ba},namep{period},'.mat'];
    load(loadname);
    
    nbses=length(weight_all);
    idx_wsess=zeros(nbses,1);
    wmax=zeros(nbses,1);
    for sess=1:nbses
        [val,idx]=max(abs(weight_all{sess}));
        idx_wsess(sess)=idx;
        wmax(sess)=weight_all{sess}(idx);
    end
    wsvm_max{ba}=wmax;
    clear weight_all
    
    
    loadname2=['auc_',namea{ba},namep{period},'.mat'];
    load(loadname2);
    %%
    wauc_max{ba}=cellfun(@max, auc);
    Ntotal=length(cell2mat(auc));
    alphac=alpha./Ntotal;
    idx_significant=round(alphac*nperm)+1;
    
    over=zeros(nbses,1);
    idx_auc_sess=cell(nbses,1);
    for sess=1:nbses
        
        auc_sess=auc{sess};
        N=size(auc_sess,1);
        h_neuron=zeros(N,1);
        
        for n=1:N
            x=auc_sess(n);
            sorted=sort(auc_perm{sess}(n,:));
            lb=sorted(idx_significant);
            ub=sorted(nperm-(idx_significant));
            if x<lb
                h_neuron(n)=1;
            elseif x>ub
                h_neuron(n)=1;
            end
            
        end
        
        
        significant_auc=find(h_neuron==1);
        
            
        if sum(significant_auc)>0
            for i=1:length(significant_auc)
                over(sess)=significant_auc(i)==idx_wsess(sess);
            end
            
        end
    end
    
    overlap{ba}=over;
    
end

%%
display(overlap{1}','overlap in V1, sessions')
display(overlap{2}','overlap in V4, sessions')
%%
figure('unit','centimeters','Position',[0,0,8,12])

for ba=1:2
    x=abs(wsvm_max{ba});
    y=abs(wauc_max{ba}-0.5);
    R=corr(x,y);
    
    subplot(2,1,ba)
    scatter(x,y,20,'k')
    lsline
    xlabel('|w_n|')
    ylabel('|AUROC-0.5|')
    
end



