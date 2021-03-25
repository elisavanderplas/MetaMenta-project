function [ret]=simmetadb(h,f,Hp,Fp,Hm,Fm,sigma,ntrials,nsubs,criteria,flat1,flatp,flatm)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Code for estimating statistical properties of empirical measurements of
%  dprime and meta-dprime (balance).
%
%  Adam Barrett August 2012.
%
% INPUTS:    h: type I hit rate
%            f:  type I false alarm rate
%            Hp: type II hit rate for positive type I responses
%            Fp: type II false alarm rate for positive type I responses
%            Hm: type II hit rate for negative type I responses
%            Fm: type II false alarm rate for negative type I responses
%            sigma: assumed ratio of signal standard deviations for stimulus B versus stimulus A (default value 1)
%            ntrials: number of trials per simulated subject
%            nsubs: number of non-excluded subjects to simulate
%            criteria: criteria for excluding subjects 1=narrow, 2=wide
%            flat1: flattening constant for empirical h and f (enter 0 for
%                   default scenario of no flattening constant)
%            flatp: flattening constant for empirical Hp and Fp (enter 0 for
%                   default scenario of no flattening constant)
%            flatm: flattening constant for empirical Hm and Fm (enter 0 for
%                   default scenario of no flattening constant)
%
% OUTPUTS:   ret.dprime: true dprime
%            ret.metadbalance: true meta-dprime-balance
%            ret.meandprime: mean empirical dprime
%            ret.sddprime: standard deviation for empirical dprime
%            ret.meanmdb: mean empirical meta-dprime
%            ret.sdmdb: standard deviation for empirical meta-dprime
%            ret.prej: probability of rejecting a subject
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute dprime
dprime=sigma*icdf('Normal',h,0,1)-icdf('Normal',f,0,1);

% Compute meta-dprime
[ret1]=metadprimepm(h,f,Hp,Fp,Hm,Fm,sigma);
metadbalance=ret1.metadprimebalance;

nrej=0; % Counter for number of rejected subjects

for k=1:nsubs % Repeat for nsubs subjects
    
    v=0;        % Only accept the subject if the data obtained enables
    while v==0; % inclusion according to the exclusion criteria
        
        % Counters for empirical hit and false alarm rates
        he=flat1;
        fe=flat1;
        Hpe=flatp;
        Hme=flatm;
        Fpe=flatp;
        Fme=flatm;
        trialf=0;
        trialh=0;
        trialHp=0;
        trialHm=0;
        trialFp=0;
        trialFm=0;
        
        for i=1:ntrials % Simulate ntrials trials
            
            s=floor(2*rand); % Variable to decide if stimulus is present
            x=rand;          % Variable to decide type I response
            if s==0                 % If stimulus absent...
                trialf=trialf+1;
                if x<f              % ... f is the chance of a false alarm.
                    fe=fe+1;
                    R=1;
                    T=0;
                else
                    R=0;
                    T=1;
                end
            else                    % If stimulus is present...
                trialh=trialh+1;
                if x<h              % ... h is the chance of a hit.
                    he=he+1;
                    R=1;
                    T=1;
                else
                    R=0;
                    T=0;
                end
            end
            y=rand;                 % Another random variable for confidence
            if T==1 && R==1         % If correct response of stimulus present...
                trialHp=trialHp+1;
                if y<Hp             % ... chance of a type II hit is Hp.
                    Hpe=Hpe+1;
                end
            elseif T==0 && R==1     % If incorrect response of stimulus present...
                trialFp=trialFp+1;
                if y<Fp             % ... chance of a type II false alarm is Fp.
                    Fpe=Fpe+1;
                end
            elseif T==1 && R==0     % If incorrect response of stimulus present...
                trialHm=trialHm+1;
                if y<Hm             % ... chance of a type II false alarm is Fp.
                    Hme=Hme+1;
                end
            else                    % If incorrect response of stimulus present...
                trialFm=trialFm+1;
                if y<Fm             % ... chance of a type II false alarm is Fp.
                    Fme=Fme+1;
                end
            end
            
        end
        
        % Compute empirical hit and false alarm rates
        he=he/trialh;
        fe=fe/trialf;
        Hpe=Hpe/trialHp;
        Fpe=Fpe/trialFp;
        Hme=Hme/trialHm;
        Fme=Fme/trialFm;
        
        % Determine whether to keep subject; if so compute d' and meta-d'
        if criteria==1
            if he~=fe && he<1 && he>0 && fe>0 && fe<1 && Hpe<1 && Hpe>0 && Fpe>0 && Fpe<1 && Hme<1 && Hme>0 && Fme>0 && Fme<1
                dpr(k)=sigma*icdf('Normal',he,0,1)-icdf('Normal',fe,0,1);
                [ret2]=metadprimepm(he,fe,Hpe,Fpe,Hme,Fme,sigma);
                metadb(k)=ret2.metadprimebalance;
                v=1;
            else
                nrej=nrej+1;
            end
        else
            if he~=fe && he<0.95 && he>0.05 && fe>0.05 && fe<0.95 && Hpe<0.95 && Hpe>0.05 && Fpe>0.05 && Fpe<0.95 && Hme<0.95 && Hme>0.05 && Fme>0.05 && Fme<0.95
                dpr(k)=sigma*icdf('Normal',he,0,1)-icdf('Normal',fe,0,1);
                [ret2]=metadprimepm(he,fe,Hpe,Fpe,Hme,Fme,sigma);
                metadb(k)=ret2.metadprimebalance;
                if ret2.stable==1
                    v=1;
                else
                    nrej=nrej+1;
                end
            else
                nrej=nrej+1;
            end
        end
    end
    
    k   % Keep track of subject number
end

ret.dprime=dprime;
ret.metadbalance=metadbalance;
ret.meandprime=mean(dpr);
ret.sddprime=std(dpr);
ret.meanmdb=mean(metadb);
ret.sdmdb=std(metadb);
ret.prej=nrej/(nrej+nsubs);
