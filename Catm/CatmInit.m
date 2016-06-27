function [catm] = CatmInit(dataobj, K, W, J, T)
%% Initialize the sampler.
% dataobj: the structure holds the data
% K: number of topics
% W: the number of unique words
% J: number of LDA initializations
% T: number of times V is sampled

D = length(dataobj.data.doc);  % number of the docs

catm.param.beta = .01;

%% Initialize v, mu, Sigma.
Sigma = eye(K-1);
nkw = zeros(K,W);
nkd = zeros(K,D);
mu = zeros(K-1,1);
v = zeros(K-1,D);
for d=1:D,
   vd = mvnrand(mu, Sigma);
   phi = exp(v2phi(vd));
   numW = length(dataobj.data.doc{d});
   catm.var.z{d} = multrand(phi, numW);
   
   for w=1:numW,
      topic = catm.var.z{d}(w);
      word = dataobj.data.doc{d}(w);
      % Generate topic-word counts.
      nkd(topic, d) = nkd(topic, d) + 1;
      nkw(topic, word) = nkw(topic, word) + 1;
   end
   v(:,d) = vd;
end
nk = sum(nkw,2);

%% Initialize from Mike Hughes LDA code.
BETA = catm.param.beta;
ALPHA = .1;
nkd = nkd';
for d=1:D,
  catm.var.z{d} = catm.var.z{d} - 1;
  dataobj.data.doc{d} = dataobj.data.doc{d} - 1;
end

for jj=1:J,
  for d=randperm(D),
     numW = length(dataobj.data.doc{d});
     [zd, nkd, nkw, nk] = LDA_sampler(catm.var.z{d}, dataobj.data.doc{d}, ...
        nkd, nkw, nk, W, D, K, ALPHA, BETA, d-1, numW);
     catm.var.z{d} = zd;
  end
end

%% Generate v, mu, Sigma.
logphi = zeros(K,D);
nkd = nkd'; % nkd is actually ndk'
for d=1:D,
  catm.var.z{d} = catm.var.z{d} + 1;
  dataobj.data.doc{d} = dataobj.data.doc{d} + 1;
  nkd(:,d) = nkd(:,d) + ALPHA;
  logphi(:,d) = log(nkd(:,d) ./ sum(nkd(:,d)));
  v(:,d) = phi2v(logphi(:,d));
  nkd(:,d) = nkd(:,d) - ALPHA;
end
mu = mean(v,2);
Sigma = cov(v');
Sigma =(Sigma+Sigma'+eye(size(Sigma))*mean(Sigma(:)))/2;

%% Initialize time distribution.
ptku = zeros(K,K);
ptkv = zeros(K,K);
ptkn = zeros(K,K);

ntku = zeros(K,K);
ntkv = zeros(K,K);
ntkn = zeros(K,K);

stku = zeros(K,1);
stkv = zeros(K,1);
stkn = zeros(K,1);

ptmu = ones(K,K)*2;
ptvar = ones(K,K)*inf;

ntmu = ones(K,K)*2;
ntvar = ones(K,K)*inf;

stmu = zeros(K,1);
stvar = ones(K,1);

tbp = ones(K,K)*0.5;

for d=1:D
    z=catm.var.z{d};
    rtime = dataobj.data.rtime{d};
    nword = size(rtime,1);

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
                    trans_rtime = trans_time(rtime(wi1,wi2));
                    ntku(z(wi1),z(wi2)) = ntku(z(wi1),z(wi2))-trans_rtime;
                    ntkv(z(wi1),z(wi2)) = ntkv(z(wi1),z(wi2))+trans_rtime^2;
                    ntkn(z(wi1),z(wi2)) = ntkn(z(wi1),z(wi2))+1;
                end
            end
        end
    end
end
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

%% Store parameters and variables.
catm.var.Sigma = Sigma;
catm.var.v = v;
catm.var.mu = mu;
catm.var.nkw = nkw;
catm.var.nkd = nkd;
catm.var.nk = nk;
catm.var.ptmu = ptmu;
catm.var.ptvar = ptvar;
catm.var.ntmu = ntmu;
catm.var.ntvar = ntvar;
catm.var.stmu = stmu;
catm.var.stvar = stvar;
catm.var.tbp = tbp;
catm.var.accept = zeros(K-1,1);
%Model parameters
catm.param.T = T;
catm.param.K = K;
catm.param.D = D;
catm.param.W = W;
