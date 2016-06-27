function [y] = mvnrand(mu, sigma)
%MVNRAND - generate multivariate normal random values 
% mu is a column vector of dimension n x 1
% sigma is a covariance matrix of n x n
n = length(mu);
y = randn(n,1);
S = chol(sigma);
y = S' * y + mu;
end

