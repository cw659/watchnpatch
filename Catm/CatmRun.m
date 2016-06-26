function catm = CatmRun(savefid, dataobj, K, W, N, J, T, S)
% K: number of topics
% W: the number of unique words
% N: number of sample rounds
% J: number of LDA initializations
% T: number of times V is sampled
% S: random seed

%% Set random seed.
rand('seed', S);

fprintf('Causal TPM\n');

%% Initialize for Gibbs sampler.
catm = CatmInit(dataobj, K, W, J, T);

%% Run sampler.
st=clock;
for n = 1:N,
    catm = CatmSample(dataobj, catm);
    if (mod(n,5) == 0),
        fprintf('Iteration %d, time: %0.4f\n',n,etime(clock,st));
        st=clock;
        if(~strcmp(savefid,''))
            save([savefid '_r' num2str(n) '.mat'], 'catm');
        end
    end
end
catm = CatmScore(dataobj, catm);

if(~strcmp(savefid,''))
    save([savefid '_r' num2str(N) '.mat'], 'catm');
end