function q3
	close all; clear;
	T = 1;
	K = 1;
	r = 0.05;
	sig = 0.6;

	time = 0:0.01:1;
	stock = 0:0.01:2;
	surface_plot(@C, stock, time, 'C', T, K, r, sig);
	surface_plot(@P, stock, time, 'P', T, K, r, sig);
end

function [y] = C(t, s, T, K, r, sig)
	d1 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r + sig^2/2)*(T-t));
	d2 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r - sig^2/2)*(T-t));
	y = s*normcdf(d1) - K*exp(-r*(T-t))*normcdf(d2);
end

function [y] = P(t, s, T, K, r, sig)
	y = C(t, s, T, K, r, sig) + K*exp(-r*(T-t)) - s;
end

function surface_plot(V, stock, time, opt, T, K, r, sig)
	figure;
	
	Z = [];
	for i = 1:length(time)
		Y = [];
		for j = 1:length(stock)
			Y = [Y, V(time(i), stock(j), T, K, r, sig)];
		end
		Z = [Z; Y];
	end

	surf(stock, time, Z);
	if opt == 'P'
		title('Put Option Value');
	else
		title('Call Option Value');
	end
	xlabel('Stock Price')
	ylabel('Time');
	zlabel('Derivative Price');
	legend('Surface plot - Price of derivative vs (t, S(t))');
	hold off;
end