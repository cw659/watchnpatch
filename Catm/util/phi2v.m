function v = phi2v(logphi)

K = size(logphi,1);
v = zeros(K-1, size(logphi,2));
temp = exp(logphi);
temp2 = flipud(cumsum(flipud(temp)));
for k = 1:K-1
    v(k,:) =  log(temp(k,:)) - log(temp2(k+1,:));
end

