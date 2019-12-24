function [smua_sgn] = smua_sign_fun(w,s_train,nbit,iW)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
dt=0.001;
J=size(s_train,1);
nstep=size(s_train,3);

nstep_mua=nstep-2*iW;

%% 

smua_sgn=cell(2,1);

for sgn=1:2
    
    if sgn==1
        idx1=find(w<0);                         % negative spikes to positive mua
        idx2=find(w>0);                         % positive spike to negative mua    
    else
        idx1=find(w>0);
        idx2=find(w<0);
    end
    
    N1=length(idx1);
    smua_raw=zeros(J,2*iW+1,N1);
    for j=1:J
        
        xn=squeeze(s_train(j,idx1,:));
        xp=squeeze(s_train(j,idx2,:));
        
        mua=mean(xp,1);                         % plus neurons for pop
        for n=1:N1
            o=xn(n,:);                          % one minus neuron for the spike train
            
            for t=iW+1:nstep-iW                   %at least t=101
                
                if o(t-1)==1
                    smua_raw(j,:,n)=smua_raw(j,:,n)+mua(1,t-iW:t+iW); %spike-triggered population activity
                end
            end
        end
    end
    
    %%
    fr=sum(mean(s_train(:,idx1,iW+1:nstep-iW),1),3)/(nstep_mua*dt);
    fr_mat=repmat(fr,2*iW+1,1);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% smua perm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%
    
    
    smua_it=zeros(nbit,2*iW+1,N1);
    
    for it=1:nbit
        
        s_perm=s_train(randperm(J),:,:);
        smua_p=zeros(J,2*iW+1,N1);
        
        for j=1:J
            
            xn=squeeze(s_perm(j,idx1,:));                            % with permuted order of trials
            xp=squeeze(s_train(j,idx2,:));                           % with regular order of trials
            
            muap=mean(xp,1);
            
            for n=1:N1
                
                o=xn(n,:);
                
                for t=iW+1:nstep-iW
                    
                    if o(t-1)==1
                        smua_p(j,:,n)=smua_p(j,:,n)+muap(1,t-iW:t+iW);
                    end
                end
            end
        end
        
        smua_it(it,:,:)=nanmean(smua_raw-smua_p,1);                   % average across trials
    end
    av_it=squeeze(nanmean(smua_it,1));         % average across iterations and normalization
    smua_sgn{sgn}=av_it./(fr_mat*nstep_mua*dt);                             
    
end

%%
%{
figure()
subplot(2,2,1)
plot(mean(smua_raw(:,:,1),1))
hold on
plot(mean(smua_raw(:,:,2),1))

subplot(2,2,2)
plot(mean(smua_p(:,:,1),1))
hold on
plot(mean(smua_p(:,:,2),1))

subplot(2,2,3)
plot(mean(smua_it(:,:,1)))
hold on
plot(mean(smua_it(:,:,2)))
%}

%%

end

