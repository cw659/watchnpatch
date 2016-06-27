function catm = CatmSample(dataobj, catm)
%% Initialize parameters.
K = catm.param.K;
D = catm.param.D;
T = catm.param.T;

beta = catm.param.beta;
accept = zeros(K-1,1);

Sigma = catm.var.Sigma;
mu = catm.var.mu;

%% Sample in random order through documents.
nkw = catm.var.nkw;
nkd = catm.var.nkd;
nk = catm.var.nk;

ptmu = catm.var.ptmu;
ptvar = catm.var.ptvar;
ntmu = catm.var.ntmu;
ntvar = catm.var.ntvar;
stmu = catm.var.stmu;
stvar = catm.var.stvar;

tbp = catm.var.tbp;
tnbp = 1-tbp;

ptku=zeros(K,K);
ptkv=zeros(K,K);
ptkn=zeros(K,K);

ntku=zeros(K,K);
ntkv=zeros(K,K);
ntkn=zeros(K,K);

stku=zeros(K,1);
stkv=zeros(K,1);
stkn=zeros(K,1);

W = catm.param.W;
betasum = beta*W;

for d=randperm(D),
    vd = catm.var.v(:,d);
    %% Sampling vd.
    for t=1:T,
      [vd, logphi, ac] = mhind3(vd, mu, Sigma, nkd(:,d), K);
      accept = accept + ac;
    end

    %% Sampling z.
    phi = exp(logphi);

    z = catm.var.z{d};
    rtime = dataobj.data.rtime{d};


    nword = size(rtime,1);

    words = dataobj.data.doc{d};
    order  = randperm(nword);
    values = rand(nword,1);
    for w = 1:nword
        wi = order(w);
        word = words(wi);
 
        oldTopic = z(wi);
        nkw(oldTopic,word) = nkw(oldTopic,word)-1;
        nkd(oldTopic,d) = nkd(oldTopic,d)-1;
        nk(oldTopic) = nk(oldTopic)-1;

        otherW = [1:wi-1 wi+1:nword];
        otherZ = z(otherW)';

        wrtime = rtime(wi,otherW);
        pt = zeros(K,1);
        for ki = 1:K
            sind=otherZ==ki;
            spt=normpdf(trans_time(wrtime(sind)),stmu(ki),stvar(ki));
            pind = otherZ~=ki&wrtime>0;
            ppt=tbp(ki,otherZ(pind)).*normpdf(trans_time(wrtime(pind)), ptmu(ki,otherZ(pind)), ptvar(ki,otherZ(pind)));
            nind = otherZ~=ki&wrtime<0;
            npt=tnbp(ki,otherZ(nind)).*normpdf(trans_time(wrtime(nind)), ntmu(ki,otherZ(nind)), ntvar(ki,otherZ(nind)));
            pt(ki)=prod([spt ppt npt]);
        end
        pt(pt==inf) = max(pt(pt~=inf));

        pt(isnan(pt))=0;

        probTopic = phi.*(nkw(:,word)+beta).*pt./(nk+betasum);

        if(~isempty(find(isnan(probTopic))))
            fprintf('nan');
            z(wi)=oldTopic;
        else
            probThresh = sum(probTopic)*values(w);
            cumProbTopic = cumsum(probTopic);
            z(wi) = find(cumProbTopic>=probThresh,1);
        end

        nkw(z(wi),word) = nkw(z(wi),word)+1;
        nkd(z(wi),d) = nkd(z(wi),d)+1;
        nk(z(wi)) = nk(z(wi))+1;
    end

    for wi1=1:nword
        for wi2=[1:wi1-1 wi1+1:nword]
            if(z(wi1)==z(wi2))
                trans_rtime = trans_time(rtime(wi1,wi2));
                stku(z(wi1)) = stku(z(wi1))+trans_rtime;
                stkv(z(wi1)) = stkv(z(wi1))+trans_rtime^2;
                stkn(z(wi1)) = stkn(z(wi1))+1;
            else
                if(rtime(wi1,wi2)>=0)
                    trans_rtime = trans_time(rtime(wi1,wi2));
                    ptku(z(wi1),z(wi2)) = ptku(z(wi1),z(wi2))+trans_rtime;
                    ptkv(z(wi1),z(wi2)) = ptkv(z(wi1),z(wi2))+trans_rtime^2;
                    ptkn(z(wi1),z(wi2)) = ptkn(z(wi1),z(wi2))+1;
                else
                    ntku(z(wi1),z(wi2)) = ntku(z(wi1),z(wi2))-trans_rtime;
                    ntkv(z(wi1),z(wi2)) = ntkv(z(wi1),z(wi2))+trans_rtime^2;
                    ntkn(z(wi1),z(wi2)) = ntkn(z(wi1),z(wi2))+1;
                end
            end
        end
    end
    %% Sample vd again.
    for t=1:T,
      [vd, logphi, ac] = mhind3(vd, mu, Sigma, nkd(:,d), K);
      accept = accept + ac;
    end
    catm.var.logphi(:,d) = logphi;
    catm.var.v(:,d) = vd;
    catm.var.z{d} = z;
end

ptmu=ones(K,K)*2;
ptvar=ones(K,K)*inf;

ntmu=ones(K,K)*2;
ntvar=ones(K,K)*inf;

stmu=zeros(K,1);
stvar=ones(K,1);

tbp=ones(K,K)*0.5;
for k1=1:K
    if(stkn(k1)>1)
        stmu(k1)=stku(k1)/stkn(k1);
        stvar(k1)=stkv(k1)/stkn(k1)-stmu(k1)^2;
        stvar(k1)=stkn(k1)/(stkn(k1)-1)*stvar(k1);
        if(stvar(k1)<=0)
            stvar(k1)=1;
        end
        stvar(k1)=sqrt(stvar(k1));
    end
    if(ptkn(k1)>1)
        ptmu(k1)=ptku(k1)/ptkn(k1);
        ptvar(k1)=ptkv(k1)/ptkn(k1)-ptmu(k1)^2;
        ptvar(k1)=ptkn(k1)/(ptkn(k1)-1)*ptvar(k1);
        if(ptvar(k1)<=0)
            ptvar(k1)=1;
        end
        ptvar(k1)=sqrt(ptvar(k1));
    end
    if(ntkn(k1)>1)
        ntmu(k1)=ntku(k1)/ntkn(k1);
        ntvar(k1)=ntkv(k1)/ntkn(k1)-ntmu(k1)^2;
        ntvar(k1)=ntkn(k1)/(ntkn(k1)-1)*ntvar(k1);
        if(ntvar(k1)<=0)
            ntvar(k1)=1;
        end
        ntvar(k1)=sqrt(ntvar(k1));
    end
    for k2=1:K
        tpb(k1,k2)=(ptkn(k1,k2)+1000)/((ptkn(k1,k2)+ntkn(k1,k2))+2000);
    end
end
%% update u and Sigma by moments.
mu=mean(catm.var.v,2);
Sigma=cov(catm.var.v');
Sigma=(Sigma+Sigma')/2;

%% Assign final values to catm struct.
catm.var.Sigma = Sigma;
catm.var.mu = mu;
catm.var.nkw = nkw;
catm.var.nk = nk;
catm.var.nkd = nkd;
catm.var.ptmu = ptmu;
catm.var.ptvar = ptvar;
catm.var.ntmu = ntmu;
catm.var.ntvar = ntvar;
catm.var.stmu = stmu;
catm.var.stvar = stvar;
catm.var.tbp = tbp;
catm.var.accept = accept;
