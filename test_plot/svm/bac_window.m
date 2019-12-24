% get time window with best BAC

close all
clear all
clc

%%

namea={'V1','V4'};
addpath=('/home/veronika/synced/struct_result/classification/svm_window/');

bac_all=cell(2,1);
for ba=1:2
    loadname=['get_window_', namea{ba},'.mat'];
    load(loadname)
    bac_all{ba}=bac_w;
end

%%

mean_bac=cellfun(@(x) mean(x,3), bac_all,'UniformOutput', false);

start_vec=[500,600,700,800,900];
L_vec=[500,400,300,200,100];

%%
best_start=zeros(2,1);
best_L=zeros(2,1);
best_bac=zeros(2,1);

for ba=1:2
    
    mb=mean_bac{ba};
    [~,idx_start]=max(mb);
    
    mbs=zeros(1,length(idx_start));
    for i=1:length(idx_start)
        mbs(i)=mb(idx_start(i),i);
    end
    
    [~,idx_L]=max(mbs);
    [val,idx_s]=max(mb(:,idx_L));
    best_bac(ba)=val;
    best_start(ba)=start_vec(idx_s);
    best_L(ba)=L_vec(idx_L);
    
end

%%

display([best_start,best_start+best_L],'best window V1/V4')
display(best_bac,'maximum BAC V1/V4')

