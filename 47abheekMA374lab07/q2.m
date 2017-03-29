function q2
	close all; clear;
	T = 1;
	K = 1;
	r = 0.05;
	sig = 0.6;

	time = [0, 0.2, 0.4, 0.6, 0.8, 1];
	stock = 0:0.01:2;
	linear_plot(@C, stock, time, 'C', T, K, r, sig);
	linear_plot(@P, stock, time, 'P', T, K, r, sig);
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

function linear_plot(V, stock, time, opt, T, K, r, sig)
	figure;
	leg = cell(size(time));

	for i = 1:length(time)
		Y = [];
		for j = 1:length(stock)
			Y = [Y, V(time(i), stock(j), T, K, r, sig)];
		end
		plot(stock, Y, 'color',rand(1,3)); hold on;
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

	data = [];
	for i = 1:length(stock)
		for j = 1:length(time)
			data = [data; stock(i), time(j), Z(j, i)];
		end
	end
	plot3(data(:, 1), data(:, 2), data(:, 3), 'o');
	if opt == 'P'
		title('Put Option Value');
	else
		title('Call Option Value');
	end
	xlabel('Stock Price')
	ylabel('Time');
	zlabel('Derivative Price');
	legend('Plot - Price of derivative vs (t, S(t))');
	hold off;
end