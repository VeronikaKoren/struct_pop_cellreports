function [smua] = smua_fun(s_train,nbit,iW)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%%
J=size(s_train,1);
N=size(s_train,2);
nstep=size(s_train,3);

%%
nstep_mua=nstep-2*iW;
dt=0.001;
fr=sum(mean(s_train(:,:,iW+1:nstep-iW),1),3)/(nstep_mua*dt);
fr_mat=repmat(fr,2*iW+1,1);

%%
smua_raw=zeros(J,2*iW+1,N);

for j=1:J
    
    xall=squeeze(s_train(j,:,:));
    
    for n=1:N
        xr=xall;
        xr(n,:)=[];                          % remove the neuron n
        mua=mean(xr,1);                      % mean across neurons               
        o=xall(n,:);
        
        for t=iW+1:nstep-iW                   %at least t=101
            
            if o(t-1)==1
                smua_raw(j,:,n)=smua_raw(j,:,n)+mua(1,t-iW:t+iW);
            end
        end
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% smua perm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%

smua_it=zeros(nbit,2*iW+1,N);

for it=1:nbit
    
    s_perm=s_train(randperm(J),:,:);                        % permute order of trials    
    smua_p=zeros(J,2*iW+1,N);
    
    for j=1:J
        
        xp_all=squeeze(s_perm(j,:,:));
        
        for n=1:N
            o=squeeze(s_train(j,n,:));
            
            xp=xp_all;
            xp(n,:)=[];                                        % remove the neuron n
            muap=mean(xp,1);
            
            for t=iW+1:nstep-iW                   
                
                if o(t-1)==1
                    smua_p(j,:,n)=smua_p(j,:,n)+muap(1,t-iW:t+iW);
                end
            end
        end
    end
    
    smua_it(it,:,:)=nanmean(smua_raw-smua_p);                       % average across trials
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
smua_nn=squeeze(mean(smua_it));                                     % average across it
smua=smua_nn./(fr_mat*nstep_mua*dt);                                % normalize with the mean f.rate, number of steps and dt


end

