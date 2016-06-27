function s = multinomial_rnd(p, n)
%multinomial_rnd     Sample from multinomial distribution
%
%    ddraw = multinomial_rnd(p, N)
%
%  Draws N independent samples from a multinomial distribution, where
%    p     = K-dim. vector of multinomial weights (possibly unnormalized)
%    ddraw = N-dim. vector containing multinomial samples in {1,...,K}

ps = cumsum(p);

if n == 1
  s = sum(ps(end)*rand(1) > ps) + 1;
else
  s = ps(end)*rand(n,1);
  for i = 1:n
    s(i) = sum(s(i) > ps) + 1;
  end
end
