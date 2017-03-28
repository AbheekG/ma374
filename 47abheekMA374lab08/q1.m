function q1
	data = flipud(csvread('bsedata1', 1, 0));
	part1(data, 'BSE');
	part2(data, 'BSE');
	% part3(data, 'BSE');

	data = flipud(csvread('nsedata1', 1, 0));
	part1(data, 'NSE');
	% part2(data, 'NSE');
	% part3(data, 'NSE');
	
end

function part1(data, market)
	fprintf('\n\nOne month historical volatility.\n');
	[m, n] = size(data);
	for i = 1:n
		if i == 1
			name = 'Index';
		else
			name = sprintf('Stock %d', i-1);
		end
		[mu, sig, S0] = volatility(data(:, i), 1);
		fprintf('%s %s,\tReturn = %f,\tVolatility = %f\n', market, name, mu, sig);
	end
end

function part2(data, market)
	fprintf('\n\nOption prices for different K, using one month historical volatility.\n');
	[m, n] = size(data);
	for i = 1:n
		if i == 1
			name = 'Index';
		else
			name = sprintf('Stock %d', i-1);
		end
		[mu, sig, S0] = volatility(data(:, i), 1);
		fprintf('\n\n%s %s\tReturn = %f,\tVolatility = %f,\tInitial Stock price = %f', market, name, mu, sig, S0);
		K = (0.5:0.1:1.5).*S0;
		fprintf('\nK = \t\t');
		for j = 1:length(K)
			fprintf('%f\t', K(j));
		end
		fprintf('\nE. Call Prices\t', market, name);
		for j = 1:length(K)
			fprintf('%f\t', C(0, S0, 0.5, K(j), 0.05, sig));
		end
		fprintf('\nE. Put Prices\t', market, name);
		for j = 1:length(K)
			fprintf('%f\t', P(0, S0, 0.5, K(j), 0.05, sig));
		end
	end
end

function part3(data, market)
	fprintf('\n\nOption prices for different K, using one month historical volatility.\n');
	[m, n] = size(data);
	for i = 1:n
		if i == 1
			name = 'Index';
		else
			name = sprintf('Stock %d', i-1);
		end
		[mu, sig, S0] = volatility(data(:, i), 1);
		fprintf('\n\n%s %s\tReturn = %f,\tVolatility = %f,\tInitial Stock price = %f', market, name, mu, sig, S0);
		K = (0.5:0.1:1.5).*S0;
		fprintf('\nK = \t\t');
		for j = 1:length(K)
			fprintf('%f\t', K(j));
		end
		fprintf('\nE. Call Prices\t', market, name);
		for j = 1:length(K)
			fprintf('%f\t', C(0, S0, 0.5, K(j), 0.05, sig));
		end
		fprintf('\nE. Put Prices\t', market, name);
		for j = 1:length(K)
			fprintf('%f\t', P(0, S0, 0.5, K(j), 0.05, sig));
		end
	end
end

function [y] = C(t, s, T, K, r, sig)
	d1 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r + sig^2/2)*(T-t));
	d2 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r - sig^2/2)*(T-t));
	y = s*normcdf(d1) - K*exp(-r*(T-t))*normcdf(d2);
end

function [y] = P(t, s, T, K, r, sig)
	y = C(t, s, T, K, r, sig) + K*exp(-r*(T-t)) - s;
end

function [mu, sig, S0] = volatility(data, mon)
	k = data(end-mon*21:end);
	S0 = data(end-mon*21);
	k = log(k);
	k = k(2:end) - k(1:end-1);
	mu = mean(k)*252;
	sig = std(k)*252^0.5;
end