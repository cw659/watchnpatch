function logphi = v2phi(v)
% converts v to log values of phi using logistic stick breaking

K = size(v,1) + 1;
logphi = zeros(K,1);

phi1 = -log(1+ exp(-v));
phi2 = -log(1 + exp(v));
logphi(1:K-1) = phi1;
logphi(2:K) = logphi(2:K) + cumsum(phi2,1);

