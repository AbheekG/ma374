function q2
	close all; clear;
	fprintf('Original Paramaters');
	T = 0.5
	K = 110	% 110, 90
	r = 0.05
	mu = 0.1
	sig = 0.2
	t = 0
	s = 100
	n = 100;
	m = 1000;

	fprintf ('\nWithout Variance Reduction\n')
	fprintf ('Asian Option Prices for K = %d\n', 105);
	fprintf ('Call = %f\n', C(t, s, T, 105, mu, r, sig, n, m, 0));
	fprintf ('Put = %f\n\n', P(t, s, T, 105, mu, r, sig, n, m, 0));

	fprintf ('Asian Option Prices for K = %d\n', 110);
	fprintf ('Call = %f\n', C(t, s, T, 110, mu, r, sig, n, m, 0));
	fprintf ('Put = %f\n\n', P(t, s, T, 110, mu, r, sig, n, m, 0));

	fprintf ('Asian Option Prices for K = %d\n', 90);
	fprintf ('Call = %f\n', C(t, s, T, 90, mu, r, sig, n, m, 0));
	fprintf ('Put = %f\n\n', P(t, s, T, 90, mu, r, sig, n, m, 0));

	
	fprintf ('\nUsing Antithetic Variables\n')
	fprintf ('Asian Option Prices for K = %d\n', 105);
	fprintf ('Call = %f\n', C(t, s, T, 105, mu, r, sig, n, m, 1));
	fprintf ('Put = %f\n\n', P(t, s, T, 105, mu, r, sig, n, m, 1));

	fprintf ('Asian Option Prices for K = %d\n', 110);
	fprintf ('Call = %f\n', C(t, s, T, 110, mu, r, sig, n, m, 1));
	fprintf ('Put = %f\n\n', P(t, s, T, 110, mu, r, sig, n, m, 1));

	fprintf ('Asian Option Prices for K = %d\n', 90);
	fprintf ('Call = %f\n', C(t, s, T, 90, mu, r, sig, n, m, 1));
	fprintf ('Put = %f\n\n', P(t, s, T, 90, mu, r, sig, n, m, 1));


	fprintf ('\nUsing Control Variates\n')
	fprintf ('Asian Option Prices for K = %d\n', 105);
	fprintf ('Call = %f\n', C(t, s, T, 105, mu, r, sig, n, m, 2));
	fprintf ('Put = %f\n\n', P(t, s, T, 105, mu, r, sig, n, m, 2));

	fprintf ('Asian Option Prices for K = %d\n', 110);
	fprintf ('Call = %f\n', C(t, s, T, 110, mu, r, sig, n, m, 2));
	fprintf ('Put = %f\n\n', P(t, s, T, 110, mu, r, sig, n, m, 2));

	fprintf ('Asian Option Prices for K = %d\n', 90);
	fprintf ('Call = %f\n', C(t, s, T, 90, mu, r, sig, n, m, 2));
	fprintf ('Put = %f\n\n', P(t, s, T, 90, mu, r, sig, n, m, 2));
end

function [y] = C(t, s, T, K, mu, r, sig, n, m, varRed)
	S_avg = 0;
	for i = 1:m
		if varRed == 0
			S = monte(s, T-t, r, sig, n);
		elseif varRed == 1
			S = monte_AV(s, T-t, r, sig, n);
		else
			S = monte_CV(s, T-t, r, sig, n);
		end

		S_avg = S_avg + mean(S);
	end
	S_avg = S_avg/m;
	
	y = exp(-r*(T-t)) * max(S_avg - K, 0);
end

function [y] = P(t, s, T, K, mu, r, sig, n, m, varRed)
	S_avg = 0;
	for i = 1:m
		if varRed == 0
			S = monte(s, T-t, r, sig, n);
		elseif varRed == 1
			S = monte_AV(s, T-t, r, sig, n);
		else
			S = monte_CV(s, T-t, r, sig, n);
		end

		S_avg = S_avg + mean(S);
	end
	S_avg = S_avg/m;

	y = exp(-r*(T-t)) * max(K - S_avg, 0);
end

% Without Var Red.
function [S] = monte(s, T, mu, sig, n)
	dt = T/n;
	Norms = normrnd(mu, sig, 1, n);
	S = [s];

	for i = 2:n+1
		s = s * (1 + mu*dt + sig*(dt^0.5)*Norms(i-1));
		S = [S, s];
	end
end

% Using Antithetic Variable
function [S] = monte_AV(s, T, mu, sig, n)
	dt = T/n;
	Norms = normrnd(mu, sig, 1, n);
	s_bak = s;
	S1 = [s];

	for i = 2:n+1
		s = s * (1 + mu*dt + sig*(dt^0.5)*Norms(i-1));
		S1 = [S1, s];
	end

	s = s_bak;
	S2 = [s];
	Norms = 2*mu - Norms;
	for i = 2:n+1
		s = s * (1 + mu*dt + sig*(dt^0.5)*Norms(i-1));
		S2 = [S2, s];
	end

	S = (S1 + S2) / 2;
end

% Using Control Variates
function [S] = monte_CV(s, T, mu, sig, n)
	dt = T/n;
	Norms = normrnd(mu, sig, 1, n);
	S = [s];

	for i = 2:n+1
		s = s * (1 + mu*dt + sig*(dt^0.5)*Norms(i-1));
		S = [S, s];
	end

	Norms = [0, Norms];
	c = cov(S, Norms);
	c = -c(1, 2)/sig;
	S = S + c*(Norms - mu);
end