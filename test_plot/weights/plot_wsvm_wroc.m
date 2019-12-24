% scatter plot between svm weights and roc weights

clear all
close all
clc

savefig=0;
saveres=0;

figname='weights_svm_roc';
savefile='/home/veronika/Dropbox/struct_pop/figure/weights/';

namea={'V1','V4'};
namep={'target','test'};
letter='E';

addpath('/home/veronika/struct_pop/result/weights/weights_regular/')
addpath('/home/veronika/struct_pop/result/classification/auc_regular/')
addpath('/home/veronika/struct_pop/result/input/spike_count/')

pos_vec=[0,0,10,9]; % size of the figure in cm

lw=1.2;
ms=5;
fs=10;
lwa=1;

%% load weights

w_svm=cell(2,2);
w_roc=cell(2,2);
w_svmp=cell(2,2);

for ba=1:2
    
    for period=1:2
        
        loadname=['auc_',namea{ba},namep{period},'.mat'];                                                 % area under the ROC curve
        load(loadname);
        w_roc{ba,period}=cell2mat(cellfun(@(x) single(x), auc,'UniformOutput', false)) ;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        loadname0=['sc_',namea{ba},'.mat'];                                                % load the input to the svm (difference of spike counts)
        load(loadname0);
        
        %d_all=cellfun(@(x,y) y-x, sc_tar, sc_test, 'UniformOutput',false);
        
        if period==1
            sc_all=sc_tar;
        else
            sc_all=sc_test;
        end
      
        var_nm=cellfun(@mean, sc_all(1,:), 'UniformOutput', false);                          % determine the sign of the input
        var_m=cellfun(@mean, sc_all(2,:), 'UniformOutput', false);
        
        sign_pos=cellfun(@(x,y) y>x, var_nm, var_m, 'UniformOutput', false);                % match > non-match gets a positive sign
        sign_neg=cellfun(@(x,y) (x>y).*(-1), var_nm, var_m, 'UniformOutput', false);        % non-match > match gets a negative sign
        
        sign_sc=cellfun(@(x,y) x+y, sign_pos,sign_neg, 'UniformOutput', false);             % vector of signs from comparison of spike counts
        sign_sc=cellfun(@(x) permute(x,[2,1]), sign_sc,'UniformOutput', false);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        loadname2=['svmw_',namea{ba},namep{period},'.mat'];                                     % load w_svm
        load(loadname2)
        
        weight_all=cellfun(@(x) permute(single(x), [2,1]), weight_all, 'UniformOutput', false); % svm weights
        sign_svm=cellfun(@sign, weight_all, 'UniformOutput', false)';                           % get sign of weights
        
        diff_sign=cellfun(@(x,y) x.*y, sign_svm, sign_sc, 'UniformOutput', false);              % where sign of weights differes from the sign of the input there is -1
        w_svm_corr_sign=cellfun(@(x,y) x.*y, diff_sign', weight_all, 'UniformOutput', false);   % correct sign of svm weights
        
        w_svm{ba,period}=cell2mat(w_svm_corr_sign);
       
    end
    
end
%%
if saveres==1
    address='/home/veronika/struct_pop/result/weights/weights_regular/';
    filename='wsvm';
    save([address, filename],'w_svm')
end

%% plot

ax=[0.2,0.8,-1.2,1.2];

H=figure('name',figname,'visible','on');
for ba=1:2
    
    for period=1:2
        
        x=w_roc{ba,period};
        y=w_svm{ba,period};
        R=corr(x,y);
        
        subplot(2,2,period+(ba-1)*2)
        hold on
        plot(x,y,'k.','markersize',ms)
        
        %% least squares line
        hl=lsline;
        B = [ones(size(hl.XData(:))), hl.XData(:)]\hl.YData(:);
        hl.Visible='off';
        Slope = B(2);
        Intercept = B(1);
        xnew=linspace(0.25,0.75,length(x));
        linear_fit=Intercept+xnew.*Slope;
        plot(xnew,linear_fit,'m','linewidth',0.5)
        hold off
        
        axis(ax)
        
        hold off
        
        text(0.6,0.1,['R = ' sprintf('%0.2f',R)],'units','normalized', 'FontName','Arial','fontsize',fs)
        if ba==1
            title(namep{period},'fontweight','normal','FontName','Arial','fontsize',fs);
        end
        
        if period==2
            text(1.03,0.5,namea{ba},'units','normalized', 'FontName','Arial','fontsize',fs)
        end
        box off
        
        line([ax(1) ax(2)],[0,0],'linestyle','--','color',[0.5,0.5,0.5])
        line( [0.5 0.5], [ax(3)+0.1 ax(4)-0.1],'linestyle','--','color',[0.5,0.5,0.5])
        
        set(gca,'XTick',[0.3,0.5,0.7])
        set(gca,'YTick',[-1,0,1])
        set(gca,'XTickLabel',[0.3,0.5,0.7], 'FontName','Arial','fontsize',fs)
        set(gca,'YTickLabel',[-1,0,1],'FontName','Arial','fontsize',fs)
        if ba==1
            set(gca,'XTickLabel',[])
        end
        if period>1
            set(gca,'YTickLabel',[])
        end
        
        set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
        
    end    
end

axes
h0=text(-0.1,1.05,letter, 'units','normalized','FontName','Arial','fontsize',fs,'FontWeight','bold');
h1 = xlabel ('Area under ROC','units','normalized','Position',[0.5,-0.07],'FontName','Arial','fontsize',fs); 
h2 = ylabel ('Weight of the SVM','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs); 

set(gca,'Visible','off')
set(h0,'visible','on')
set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) 
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) 

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

