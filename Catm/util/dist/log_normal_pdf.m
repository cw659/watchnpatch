function y = log_normal_pdf(x, mu, sigma)
% Returns the log probability of the normal pdf
% sigma is the variance
y = -0.5 * ((x - mu).^2) ./sigma - .5*log(2*pi* sigma);