% distinguish informative and less informative neurons

clear all 
close all
clc

saveres=1;
showfig=1;
period=2;

ba=1;
window=3;
%%

namea={'V1','V4'};
namep={'target','test'};
namew={'','first_half_','second_half_'};

task=['determine informative and less informative neurons in ', namea{ba},namep{period}];
disp(task)
%%

addpath '/home/veronika/synced/struct_result/weights/weights_regular/';
addpath '/home/veronika/synced/struct_result/weights/weights_permuted/';

loadname=['svmw_',namew{window},namea{ba},namep{period}];
load(loadname)

loadname2=['svmw_perm_',namew{window},namea{ba},namep{period}];
load(loadname2)
nbses=size(weight_all,1);

%%
nperm=size(weight_perm_all{1},2);    
alpha=0.3;
idx=alpha*nperm;

tag_info=cell(nbses,1);
for sess=1:nbses
    
    w=weight_all{sess};
    wp=weight_perm_all{sess};
    N=length(w);
    %%
    tag=zeros(N,1);
    for n=1:N
        
        sorted=sort(wp(n,:));
        lb=sorted(idx);         % lower bound
        ub=sorted(end-idx+1);   % upper bound
        tag(n)=or(w(n)<lb,w(n)>ub);
        
    end 
    tag_info{sess}=int8(tag);
    
end
%%
perc_info=sum(cell2mat(tag_info))./numel(cell2mat(tag_info));
display(perc_info,'percent informative');
%%
if showfig==1
    cs=1;
    figure()
    hold on
    boxplot(weight_perm_all{cs}')
    plot(weight_all{cs})
    plot(tag_info{cs}*100 -99,'k*')
    ylim([-1,1.3])
end
%%
if saveres==1
    
    savename=['tag_info_',namea{ba},namep{period},'_',namew{window}];
    savefile='/home/veronika/synced/struct_result/weights/tag/';    
    save([savefile,savename],'tag_info','alpha')
    
end

