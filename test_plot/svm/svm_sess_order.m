% plot balanced accuracy in sessions and average across sessions

format long

clear all
close all
clc


saveorder=1;
period=2;

namep={'target','test'};
namea={'V1','V4'};
namet='regular';

%% load the results of the linear SVM


addpath '/home/veronika/synced/struct_result/classification/svm_regular/'

sess_order=cell(2,1); % {area} (nbses,1);

for ba=1:2
        
    loadname=['svm_regular_',namea{ba},namep{period},'.mat'];
    load(loadname);
    
    [~,idx]=sort(bac_all);
    order=flip(idx);
    sess_order{ba}=order;
    
 
end

%%
if period==2
    if saveorder==1
        
        address='/home/veronika/synced/struct_result/classification/svm_regular/';
        filename=['svm_session_order_',namep{period}];
        save([address, filename],'sess_order')
        
    end
end
