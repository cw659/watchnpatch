function y = normrand(mu, sigma, M)

%Generates a matrix of normal random valued gaussian variables
y = randn(length(mu),M) * sqrt(sigma);
y = y + repmat(mu(:),1,M);