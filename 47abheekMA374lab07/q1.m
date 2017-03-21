function q1
end

function [C, P] = european_prices(t, s, T, K, r, sig)
	syms x;
	f(x) = exp(-x^2/2)/(2*pi)^0.5;
	N(x) = int(f(x));
	d1 = (1/sig*(T-t)^0.5) * (log(s/K) + (r + sig^2/2)*(T-t));
	d2 = (1/sig*(T-t)^0.5) * (log(s/K) + (r - sig^2/2)*(T-t));

	C(t, s) = s*N(d1) - K*exp(-r*(T-t))*N(d2);
	P(t, s) = C(t, s) + K*exp(-r*(T-t)) - s;
end