function [pi] = genPI(dcnt, find)

K = dcnt.param.K; % number of topics
F = size(find,2); % number of features
pi = zeros(K,F);
N = 10000;
% prepare probability masses pi
for f = 1:F, % loop through topics
    phiF = zeros(dcnt.param.F,1);
    phiF(find{f}) = 1;
    % Generate v
    temp = zeros(N,K);
    muV = dcnt.var.A*dcnt.var.eta' * phiF;
    covV = 1/dcnt.var.lambdaV * eye(K-1) + dcnt.var.A*dcnt.var.A';
    for n=1:N,
        temp(n,:) = exp(v2pi(mvnrand(muV, covV)));
    end
    pi(:,f) = mean(temp,1);
end