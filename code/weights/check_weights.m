
clear all
close all
clc

saveres=1;
showfig=1;

ba=1;
period=2;

namea={'V1','V4'};
namep={'target','test'};

%% check weights regular permuted

addpath('/home/veronika/struct_pop/result/weights/weights_regular/')
addpath('/home/veronika/struct_pop/result/weights/weights_permuted/')

loadname=['svmw_',namea{ba},namep{period},'.mat'];                                          
load(loadname)

loadname2=['svmw_perm_',namea{ba},namep{period},'.mat'];                                          
load(loadname2)

nbses=size(weight_all,1);

%% 100-alpha boundary

nperm=size(weight_perm_all{1},1);
alpha=0.25;
si=round(nperm*alpha);

high=cell(nbses,1);
low=cell(nbses,1);
medium=cell(nbses,1);

lb_all=cell(nbses,1);
ub_all=cell(nbses,1);

for i=1:nbses
    
    w=double(weight_all{i}');
    N=size(w,1);
    
    lb=zeros(N,1);
    ub=zeros(N,1);
    for n=1:N
        x=double(weight_perm_all{i}(:,n));
        [val,idx]=sort(x);
        lb(n)=val(si);
        ub(n)=val(end-si);
    end
    
    %% get index
    
    idx_h=find(w>ub);
    idx_l=find(w<lb);
    idx_m=(1:N)';
    idx_m([idx_l;idx_h])=[];
    
    low{i}=idx_l;
    high{i}=idx_h;
    medium{i}=idx_m;
    
    ratio=(length(idx_h)+length(idx_l))/length(idx_m);
    
    %% get bounds
    
    lb_all{i}=lb;
    ub_all{i}=ub;
    
   
    
end

%%

if showfig==1
    
    x=cell2mat(cellfun(@(x) permute(x,[2,1]),weight_all,'UniformOutput',false));
    xlow=cell2mat(lb_all);
    xhigh=cell2mat(ub_all);
    Ntot=length(x);
    [~,order]=sort(x);
    
    figure()
 
    hold on
    plot(1:Ntot,x(order),'k','linewidth',2)
    plot(1:Ntot,xlow(order),'m', 'linewidth',2)
    plot(1:Ntot,xhigh(order),'m','linewidth',2)
    xlim([1,Ntot])
    ylim([-1.2,1.2])
    text(0.75,0.9,['\alpha=',sprintf('%0.2f',alpha)],'units','normalized')
    set(gca,'XTick',50:50:100)
    xlabel('neuron index')
    ylabel('weight')

end
%% save result

if saveres==1
    
    address='/home/veronika/struct_pop/result/weights/weights_info/';
    filename=['w_info_', namea{ba},namep{period}];
    save([address, filename],'low','high','medium')
     
end
