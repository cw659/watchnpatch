function catm = CatmScore(dataobj, catm)

%% Initialize parameters
K = catm.param.K;
D = catm.param.D;

beta = catm.param.beta;

%% Sample in random order through documents
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

W = catm.param.W;
betasum =  beta*W;

for d=1:D,
    
    pi = exp(catm.var.logpi(:,d));
	
	z = catm.var.z{d};
    rtime = dataobj.data.rtime{d};
    rtime(rtime>=0)=1./(1-rtime(rtime>=0))-1;
    rtime(rtime<0)=1-1./(1+rtime(rtime<0));
%     srtime = (rtime+1)/2;
        
    nword = size(rtime,1);
    
    words = dataobj.data.doc{d};
    
    score = zeros(nword,1);
    
    for wi = 1:nword
        word = words(wi);
        Topic = z(wi);
        
        nkw(Topic,word) = nkw(Topic,word)-1;
        nkd(Topic,d) = nkd(Topic,d)-1;
        nk(Topic) = nk(Topic)-1;

        otherW = [1:wi-1 wi+1:nword];
        
        otherZ = z(otherW)';
        wrtime = rtime(wi,otherW);
%         wsrtime = srtime(wi,otherW);
        ki = Topic;
%         for ki=1:K
            sind=otherZ==ki;
            spt=normpdf(wrtime(sind),stmu(ki),stvar(ki));
            pind=otherZ~=ki&wrtime>=0; 
%             ppt=gammapdf(wrtime(pind),ptmu(ki,otherZ(pind)),ptvar(ki,otherZ(pind)));
            ppt=tbp(ki,otherZ(pind)).*gammapdf(wrtime(pind),ptmu(ki,otherZ(pind)),ptvar(ki,otherZ(pind)));
%             ppt=tbp(ki,otherZ(pind)).*gampdf(wrtime(pind),ptmu(ki,otherZ(pind)),ptvar(ki,otherZ(pind)));
%             ppt=tbp(ki,otherZ(pind)).*betapdf(wrtime(pind),ptmu(ki,otherZ(pind)),ptvar(ki,otherZ(pind)));
            nind=otherZ~=ki&wrtime<0;
%             npt=gammapdf(-wrtime(nind),ntmu(ki,otherZ(nind)),ntvar(ki,otherZ(nind)));
            npt=tnbp(ki,otherZ(nind)).*gammapdf(-wrtime(nind),ntmu(ki,otherZ(nind)),ntvar(ki,otherZ(nind)));
%             npt=tnbp(ki,otherZ(nind)).*gampdf(-wrtime(nind),ntmu(ki,otherZ(nind)),ntvar(ki,otherZ(nind)));
%             npt=tnbp(ki,otherZ(nind)).*betapdf(-wrtime(nind),ntmu(ki,otherZ(nind)),ntvar(ki,otherZ(nind)));
            pt=prod([spt ppt npt]);
%         end

%         pt(pt==inf) = max(pt(pt~=inf));
%         
%         pt(isnan(pt))=0;
        
        score(wi) = pi(Topic).*(nkw(Topic,word)+beta).*pt./(nk(Topic)+betasum);
        
        nkw(z(wi),word) = nkw(z(wi),word)+1;
        nkd(z(wi),d) = nkd(z(wi),d)+1;
        nk(z(wi)) = nk(z(wi))+1;
    end

    catm.var.score{d} = score;
end