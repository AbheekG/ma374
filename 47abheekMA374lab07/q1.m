function q1
	@C;
	@P;
end

function [y] = C(t, s, T, K, r, sig)
	d1 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r + sig^2/2)*(T-t));
	d2 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r - sig^2/2)*(T-t));
	y = s*normcdf(d1) - K*exp(-r*(T-t))*normcdf(d2);
end

function [y] = P(t, s, T, K, r, sig)
	y = C(t, s, T, K, r, sig) + K*exp(-r*(T-t)) - s;
end