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
betasum = beta*W;

for d=1:D,
    
    pi = exp(catm.var.logphi(:,d));
	
	z = catm.var.z{d};
    rtime = dataobj.data.rtime{d};
        
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
        ki = Topic;
        sind=otherZ==ki;
        spt=normpdf(trans_time(wrtime(sind)),stmu(ki),stvar(ki));
        pind = otherZ~=ki&wrtime>0;
        ppt=tbp(ki,otherZ(pind)).*normpdf(trans_time(wrtime(pind)), ptmu(ki,otherZ(pind)), ptvar(ki,otherZ(pind)));
        nind = otherZ~=ki&wrtime<0;
        npt=tnbp(ki,otherZ(nind)).*normpdf(trans_time(wrtime(nind)), ntmu(ki,otherZ(nind)), ntvar(ki,otherZ(nind)));
        pt=prod([spt ppt npt]);
        
        score(wi) = pi(Topic).*(nkw(Topic,word)+beta).*pt./(nk(Topic)+betasum);
        
        nkw(z(wi),word) = nkw(z(wi),word)+1;
        nkd(z(wi),d) = nkd(z(wi),d)+1;
        nk(z(wi)) = nk(z(wi))+1;
    end

    catm.var.score{d} = score;
end