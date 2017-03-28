% function q1
% 	syms t s T K r sig;
% 	[C, P] = european_prices(t, s, T, K, r, sig);
% 	C
% 	P
% end

% function [C, P] = european_prices(t, s, T, K, r, sig)
% 	syms x;
% 	f(x) = exp(-x^2/2)/(2*pi)^0.5;
% 	N(x) = int(f(x));
% 	d1 = (1/sig*(T-t)^0.5) * (log(s/K) + (r + sig^2/2)*(T-t));
% 	d2 = (1/sig*(T-t)^0.5) * (log(s/K) + (r - sig^2/2)*(T-t));

% 	C(t, s) = s*N(d1) - K*exp(-r*(T-t))*N(d2);
% 	P(t, s) = C(t, s) + K*exp(-r*(T-t)) - s;
% end

function q2_half
	close all; clear;
	T = 1;
	K = 1;
	r = 0.05;
	sig = 0.6;
	syms t s;
	[C(t, s), P(t, s)] = european_prices(t, s, T, K, r, sig);

	time = [0, 0.2, 0.4, 0.6, 0.8, 1];
	stock = 0.01:0.01:2;
	linear_plot(C, stock, time, 'C');
	% linear_plot(P, stock, time, 'P');
	% surface_plot(C, stock, time, 'C');
	% surface_plot(P, stock, time, 'P');
end

function [C, P] = european_prices(t, s, T, K, r, sig)
	syms x;
	f(x) = exp(-x^2/2)/(2*pi)^0.5;
	N(x) = int(f(x));
	d1 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r + sig^2/2)*(T-t));
	d2 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r - sig^2/2)*(T-t));

	C(t, s) = s*N(d1) - K*exp(-r*(T-t))*N(d2);
	P(t, s) = C(t, s) + K*exp(-r*(T-t)) - s;
end

function linear_plot(V, stock, time, opt)
	figure;
	leg = cell(size(time));

	for i = 1:length(time)
		Y = [];
		for j = 1:length(stock)
			Y = [Y, V(time(i), stock(j))];
		end
		plot(stock, Y); hold on;
		leg{i} = sprintf('t = %f', time(i));
	end

	if opt == 'P'
		title('Put Option Value');
	else
		title('Call Option Value');
	end
	xlabel('Stock Price')
	ylabel('Derivative Price');
	legend(leg);
	hold off;
end