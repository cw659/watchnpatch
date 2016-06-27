function [COV CORR C temp] = covpi(dcnt, N)
%% Monte Carlo Estimate of Pi
% Returns covariance and correlation matrices across all documents
D = dcnt.param.D;
K = dcnt.param.K;

% Marginalized covariance of v
meanV = dcnt.var.A*dcnt.var.eta' * dcnt.var.phiF;
covV = 1/dcnt.var.lambdaV * eye(K-1) + dcnt.var.A*dcnt.var.A';
% Initialize data structures
temp = zeros(N,K);
sampcov = zeros(N,K,K);
C = zeros(D,K,K);
%sampcorr = zeros(N,K,K);
% Run Monte Carlo Estimate
for d = 1:D,
    for n=1:N,
        temp(n,:) = exp(v2pi(mvnrand(meanV(:,d), covV)));
    end
    meanK = mean(temp,1);
    temp = temp - repmat(meanK, N, 1);
    for n=1:N,
        sampcov(n,:,:) = temp(n,:)' * temp(n,:);
    end
    C(d,:,:) = squeeze(mean(sampcov,1));
end
COV = squeeze(mean(C,1));
CORR = COV ./ (sqrt(diag(COV)) * sqrt(diag(COV))'); 