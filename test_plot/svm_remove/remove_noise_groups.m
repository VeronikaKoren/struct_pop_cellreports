% tests and plots difference between the regular model and the model with
% removed structure within subpopulation of neurons with the same sign of
% the weight
% testing with the permutation test on the p-value using the balanced accuracy

format long

clear all
close all
clc

savefig=1;
window=1;         

%%
period=2;
alpha=0.05;                                                                     % significance threshold

namea={'V1','V4'};
namep={'target','test'};
namew={'','_first_half','_second_half'};
namer={'regular','window','window'};

figname=['remove_noise_groups',namew{window}];
savefile='/home/veronika/Dropbox/struct_pop/figure/final/';

pos_vec=[0,0,11.4,8.5];                                                            % figure size in cm [x_start, y_start, width, height]

lw=1.0;                                                                         % linewidth
ms=6;                                                                           % markersize
fs=10;                                                                          % fontsize
lwa=1;                                                                          % linewidth for figure borders

%% load results of the regular model

addpath(['/home/veronika/synced/struct_result/classification/svm_',namer{window},'/'])
addpath('/home/veronika/synced/struct_result/classification/svm_remove_noise/')


acc=cell(2,1);                                                                  
acc_perm=cell(2,1);                                                           

acc3=cell(2,1); 
acc3_perm=cell(2,1);

for ba=1:2
    
    if window==1   
        loadname=['svm_',namer{window},'_',namea{ba},namep{period},'.mat'];
        load(loadname);
        acc{ba}=bac_all;
        acc_perm{ba}=bac_allp;
    else
        loadname=['svm_window_regular',namea{ba},namep{period},'.mat'];
        load(loadname);
        acc{ba}=bac_halfw(window-1,:)';
        
        loadname0=['svm_window_permuted',namea{ba},namep{period},'.mat'];
        load(loadname0);
        acc_perm{ba}=squeeze(bac_halfwp(window-1,:,:));
       
    end
    %{
    loadname=['svm_regular_',namea{ba},namep{period},'.mat'];
    load(loadname);
   
    acc{ba}=bac_all;        
    acc_perm{ba}=bac_allp;
    %}
    clear bac_all
    clear bac_allp
    
    loadname3=['svm_groups_remove_noise_', namea{ba},namep{period},namew{window}];
    load(loadname3);
    
    acc3{ba}=bac_all;      
    acc3_perm{ba}=bac_allp;
    
end

addpath '/home/veronika/synced/struct_result/classification/svm_regular/'
loadname3='svm_session_order_test';
load(loadname3);


%% get difference w.r.t the regular model

d_sess=cellfun(@(x,y) x-y, acc3,acc,'UniformOutput', false);                                                       % compute the difference bac_permuted - bac_regular 
d=cellfun(@mean, d_sess);                                                                                          %  average across sessions
d_perm=cellfun(@(x,y) x-y, acc3_perm,acc_perm,'UniformOutput',false);
dp=cell2mat(cellfun(@mean,d_perm,'UniformOutput', false));              

%%  test: removing noise correlations within coding pools decreases classification performance

pval=zeros(2,1);

for ba=1:2
    
    x=d(ba);
    x0=dp(ba,:);
    
    pval(ba)=sum(x>x0)/length(x0);    

end


hyp=pval<alpha/(numel(pval));
display(pval,'p-value permutation test on the hypothesis: removing structure within coding pools decreases classification performance')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot session average and results in individual sessions

ylimit=[-0.2,0.2];
yt=-0.1:0.1:0.1;
xt=[1,7,14;1,4,8];

pltidx={[1,2],[4,5]};
col={'r',[0.7,0.7,0.7,0.5]};

H=figure('name',figname,'visible','on');

for ba=1:2
    
    y=d_sess{ba};
    order=sess_order{ba}  ;                                                % from big to small
    y0=d_perm{ba}(order,:);
    
    subplot(2,3, pltidx{ba})
    hold on
    bs=boxplot(y0','colors',[0.5,0.5,0.5]);
    plot(y(order),'x','color',col{1},'markersize',ms,'Linewidth',lw+0.5);
    plot(0:length(y)+1,zeros(length(y)+2,1),'--','color',[0.2,0.2,0.2,0.7],'linewidth',lw)
    hold off
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    
    xlim([0,length(y)+1])
    ylim(ylimit)
    box off
    
    if and(ba==1,window==1)==1
        text(0.05,0.92,'removed noise corr. across pools','units','normalized','color',col{1},'fontsize',fs,'FontName','Arial')
        text(0.05,0.8,'permuted label','units','normalized','color',[0.5,0.5,0.5,0.5],'fontsize',fs,'FontName','Arial')
    end
    
    set(gca,'XTick',xt(ba,:))
    set(gca,'XTickLabel',xt(ba,:))
    set(gca,'YTick',yt)
    set(gca,'YTickLabel',yt*100,'fontsize',fs)
    grid on
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
     
end
yt2=-0.02:0.02:0.02;
ylim2=[-0.04,0.04];

pltidx=[3,6];

for ba=1:2
    
    x=d(ba);
    x0=dp(ba,:);
    
    subplot(2,3,pltidx(ba))
    hold on
    bs=boxplot(x0','colors',[0.5,0.5,0.5]);
    set(bs,{'linew'},{1})
    plot(1,x(1),'+','color',col{1},'markersize',ms,'Linewidth',lw+1);
    plot(0:4,zeros(5,1),'--','color',[0.5,0.5,0.5,0.5],'linewidth',lw)
    grid on
    
    hold off
    
    text(1.05,0.5,namea{ba},'units','normalized', 'FontName','Arial','fontsize',fs)
    xlim([0.5,1.5])
    ylim(ylim2)
    box off
    
    hout=findobj(gca,'tag','Outliers');
    delete(hout)
    set(gca,'YTick',yt2)
    set(gca,'YTickLabel',yt2*100,'fontsize',fs, 'FontName','Arial','fontsize',fs)  
    set(gca,'XTick',1)
    set(gca,'XTickLabel',[])
  
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
      
end

axes
h1 = xlabel ('Session index (sorted w.r.t. regular)','Position',[0.3,-0.07],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Difference in accuracy w.r.t. regular (percent)','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    print(H,[savefile,figname],'-dtiff','-r300');
end

