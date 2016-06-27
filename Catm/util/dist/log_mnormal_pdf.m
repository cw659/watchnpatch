function y = log_mnormal_pdf(x, mu, sigma)
%Sigma is the DxD covariance matrix
%mu is a Dx1 mean vector
%x is a Dx1 observations vector
D = size(sigma,1);
y = (-D/2) * log(2*pi) - .5*sum(log(eig(sigma))) - .5 * (x-mu)' * (sigma \ (x-mu)); 