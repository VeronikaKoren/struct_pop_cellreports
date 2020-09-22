% plot balanced accuracy in sessions and average across sessions

format long

clear all
close all
clc

saveres=0;
period=2;
ba=1;

namep={'target','test'};
namea={'V1','V4'};

%% load the results of the linear SVM

addpath '/home/veronika/synced/struct_result/classification/bac_nneur/'

loadname=['svm_nneur_',namea{ba},namep{period},'.mat'];
load(loadname);

%%

bacn=cellfun(@(x) mean(x,2),bac_neurons,'UniformOutput', false);
bac_sem=cellfun(@(x) (std(x')./sqrt(size(x,1)))',bac_neurons,'UniformOutput', false);
nmax=max(cellfun(@(x) size(x,1),bacn));
nbses=length(bacn);

%%

figure('visible','off')
hold on
for sess=1:nbses
    y1=(bacn{sess}-bac_sem{sess})';
    y2=(bacn{sess}+bac_sem{sess})';
    x=1:length(y1);
    patch([x fliplr(x)], [y1 fliplr(y2)], 'r','FaceAlpha',0.3,'EdgeColor','k')
    xlim([1,nmax+2])
    %plot(xvec(1:length(y)),y,'k')
end
hold off
xlabel('number of neurons')
ylabel('balanced accuracy')

%% average across sessions

bac_padded=zeros(nbses,nmax);
sem_padded=zeros(nbses,nmax);
for sess=1:nbses
    
    y=bacn{sess};
    y1=bac_sem{sess};
    npad=nmax-length(y);
    bac_padded(sess,:)=cat(1,y,zeros(npad,1));
    sem_padded(sess,:)=cat(1,y1,zeros(npad,1));
end

%%

bac_average=zeros(nmax,1);
sem_average=zeros(nmax,1);
for nn=1:nmax
    
    z=bac_padded(:,nn);
    znon=nonzeros(z);
    bac_average(nn)=mean(znon);
    
    z1=sem_padded(:,nn);
    z1non=nonzeros(z1);
    sem_average(nn)=mean(z1non);
    
end

%% session average

y1=(bac_average-sem_average)';
y2=(bac_average+sem_average)';
x=1:nmax;

figure('visible','off')
hold on
patch([x fliplr(x)], [y1 fliplr(y2)], 'r','FaceAlpha',0.3,'EdgeColor','k')
xlim([1,nmax+2])


%%
if saveres==1
    address='/home/veronika/synced/struct_result/classification/bac_nneur/';
    filename=['nneur_',namea{ba},namep{period}];
    save([address, filename],'bacn','bac_sem','bac_average','sem_average')
end

