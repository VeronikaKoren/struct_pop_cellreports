function [ccg] = ccg_fun(spike_train,nshuffle)
% computes cross-correlograms for all to all cells
% shuffled correction
% computes the normalized sum around the 0 lag within the bincorr interval
% nomalization with sqrt(autocorr_cell1*autocorr_cell2)
%%
 
N=size(spike_train,2);
J=size(spike_train,1);
npair=(N^2-N)/2;
K=size(spike_train,3);

%% cross-correlation function

cross_all=zeros(J,npair,2*K-1);

for j=1:J                                                       % trial
    idx=0;
    for i = 1 : N-1                                             % first cell
        x=squeeze(spike_train(j,i,:));
        
        for m= i+1:N                                            % second cell
            idx=idx+1 ;   
            y=squeeze(spike_train(j,m,:));
            cross_all(j,idx,:)=xcorr(x,y,'Coeff');              % "coeff" normalizes so that the autocorrelation at zero lag is zero
            
        end
    end
end

cross=squeeze(nanmean(cross_all)); % average across trials (cross-correlogram)


%% trial invariant ccg

cross_inv_p=zeros(nshuffle,npair,2*K-1);

for p=1:nshuffle
    
    cross_inv_all=zeros(J,npair,2*K-1);
    pt=randperm(J);
    for j=1:J
        idx=0;
        for i = 1 : N-1
            
            x=squeeze(spike_train(pt(j),i,:));
            
            for m= i+1:N
                idx=idx+1;
                y=squeeze(spike_train(j,m,:));
                
                cross_inv_all(j,idx,:)=xcorr(x,y,'Coeff');
                
            end
        end
    end
    
    cross_inv_p(p,:,:)=squeeze(nanmean(cross_inv_all));                     % mean across trials
end

cross_inv=squeeze(mean(cross_inv_p,1)); 

ccg=cross-cross_inv;                                                        % mean across shuffles

if size(ccg,2)==1
    ccg=ccg';
end

end
