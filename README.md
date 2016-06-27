# watchnpatch

Catm: Causal topic model.
Run the training
catm = CatmRun(savefid, dataobj, K, W, N, J, T, S)
% K: number of topics
% W: the number of unique words
% N: number of sample rounds
% J: number of LDA initializations
% T: number of times V is sampled
% S: random seed
% dataobj.data.doc a cell of docs, each of which is a word index vector
% dataobj.data.rtime a cell of doc's relative time, each of which is nword*nword matrix
