function [ccg] = ccg_pm_fun(spike_train,w,nshuffle)
% computes cross-correlograms for all to all cells
% shuffled correction
% computes the normalized sum around the 0 lag within the bincorr interval
% nomalization with sqrt(autocorr_cell1*autocorr_cell2)
%%
 
neg=find(w<0);
pos=find(w>0);

ncell_pos=length(pos);
ncell_neg=length(neg);

spikes=cell(2,1);
spikes{1}=spike_train(:,neg,:);
spikes{2}=spike_train(:,pos,:);

J=size(spike_train,1);
npair=length(pos)*length(neg);
K=size(spikes{1},3);

%% cross-correlation function

cross_all=zeros(J,npair,2*K-1);

for j=1:J
    idx=0;
    for i = 1 : ncell_neg 
        x=squeeze(spikes{1}(j,i,:));
        
        for m= 1:ncell_pos
            idx=idx+1;    
            y=squeeze(spikes{2}(j,m,:));
            
            cross_all(j,idx,:)=xcorr(x,y,'Coeff');
            
        end
    end
end

cross=squeeze(nanmean(cross_all));

%% trial invariant ccg

cross_inv_p=zeros(nshuffle,npair,2*K-1);

for p=1:nshuffle
    
    cross_inv_all=zeros(J,npair,2*K-1);
    pt=randperm(J);
    for j=1:J
        idx=0;
        for i = 1 : ncell_neg
            
            x=squeeze(spikes{1}(pt(j),i,:));
            
            for m= 1:ncell_pos
                idx=idx+1;
                y=squeeze(spikes{2}(j,m,:));
                
                cross_inv_all(j,idx,:)=xcorr(x,y,'Coeff');
                
            end
        end
    end
    
    cross_inv_p(p,:,:)=squeeze(nanmean(cross_inv_all));
end

cross_inv=squeeze(mean(cross_inv_p,1));
ccg=cross-cross_inv;                                                            % ccg noise
%}

if size(ccg,2)==1
    ccg=ccg';
end


end
