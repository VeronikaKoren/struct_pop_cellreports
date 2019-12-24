% 

close all
clear all
clc 
format long

saveres=0;
showfig=1;

ba=1;
period=2;
chosen_bin=2;                                                                   % [20,50];

start_vec=[200,500];                                                             % beginning of the time window for the target (200) and the test stimulus (500) 
start=start_vec(period);
K=500;

blv=[20,50];
bin_length=blv(chosen_bin);
    
display(['noise correlation of binned spike count with bin length ', sprintf('%1.0i',bin_length)])

%% load spike counts

namea={'V1','V4'};
namep={'target', 'test'};

addpath('/home/veronika/Dropbox/struct_pop/code/function/')
addpath('/home/veronika/synced/struct_result/input/')

loadname=['spike_train_',namea{ba},'_',namep{period}];
load(loadname);

strain=cellfun(@(x,y) single(cat(1,x,y)),spiketrain(:,1),spiketrain(:,2), 'UniformOutput', false);  % concatenate conditions
stime=cellfun(@(x) x(:,:,start:start+K-1),strain,'UniformOutput',false);                            % take the desired time window
nbses=length(stime);

%% compute binned spike counts

idx1=1:bin_length:K-bin_length+1;
idx2=bin_length:bin_length:K;
B=length(idx1);

binc=cell(nbses,1);
for sess=1:nbses
    
    vs=stime{sess};
    J=size(vs,1);
    N=size(vs,2);
    
    count_vec=zeros(N,J*B);
    for n=1:N
        count=zeros(size(vs,1),length(idx1));
        for j=1:J
            for b=1:B     
                count(j,b)=sum(vs(j,n,idx1(b):idx2(b)));
            end
        end
        count_norm=(count-repmat(nanmean(count),J,1))./repmat(nanstd(count),J,1);   % z-score every bin
        
        count_vec(n,:)=count_norm(:);
    end
    binc{sess}=count_vec;
end


%%

rb=[];    

for ss=1:nbses                                                                  % recording sessions
    
    scb=binc{ss};
    N=size(scb,1);
    Np=(N^2-N)/2;
    
    rb_sess=zeros(Np,1);
    
    counter=0;
    for n=1:N-1
        
        x=scb(n,:);
        
        for m=n+1:N
            counter=counter+1;
            
            y=scb(m,:);
            rb_sess(counter)=corr(x',y');
        end
    end
        
    rb=cat(1,rb,rb_sess);

end
   
%%

if showfig==1
    
    [x, vec]=ksdensity(rb);
    
    figure()
    plot(vec,x./sum(x))
    title('distribution of r_{sc} noise for binned spike trains')
    xlabel('r_{sc} noise ')
    ylabel('probability dstribution')
    
end

%% save result

if saveres==1
    address=['/home/veronika/synced/struct_result/pairwise/rb',sprintf('%1.0i',bin_length),'/rb',sprintf('%1.0i',bin_length),'_1c/'];
    filename=['rb',sprintf('%1.0i',bin_length),'_1c_',namea{ba},'_',namep{period}];
    save([address,filename],'rb')
end
