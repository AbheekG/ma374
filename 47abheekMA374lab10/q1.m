function q1
	close all; clear;
	fprintf('Original Paramaters');
	T = 0.5
	K = 105	% 110, 90
	r = 0.05
	mu = 0.1
	sig = 0.2
	t = 0
	s = 100
	n = 100;
	m = 100;

	simulate_paths(s, t, T, mu, sig, n, 'RealWorld');
	simulate_paths(s, t, T, r, sig, n, 'RiskNeutralWorld');

	fprintf ('Asian Option Prices for K = %d\n', 105);
	fprintf ('Call = %f\n', C(t, s, T, 105, mu, r, sig, n, m));
	fprintf ('Put = %f\n\n', P(t, s, T, 105, mu, r, sig, n, m));

	fprintf ('Asian Option Prices for K = %d\n', 110);
	fprintf ('Call = %f\n', C(t, s, T, 110, mu, r, sig, n, m));
	fprintf ('Put = %f\n\n', P(t, s, T, 110, mu, r, sig, n, m));

	fprintf ('Asian Option Prices for K = %d\n', 90);
	fprintf ('Call = %f\n', C(t, s, T, 90, mu, r, sig, n, m));
	fprintf ('Put = %f\n\n', P(t, s, T, 90, mu, r, sig, n, m));

	vary_one(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'T');
	vary_one(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'T');

	vary_one(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'K');
	vary_one(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'K');

	vary_one(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'mu');
	vary_one(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'mu');

	vary_one(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'r');
	vary_one(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'r');
	
	vary_one(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'sig');
	vary_one(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'sig');

	vary_one(@C, s, t, 'C', T, K, mu, r, sig, n, m, 't');
	vary_one(@P, s, t, 'P', T, K, mu, r, sig, n, m, 't');

	vary_one(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'S');
	vary_one(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'S');

	% Doing for r, sig, t, S
	vary_two(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'r', 'sig');
	vary_two(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'r', 'sig');
	
	vary_two(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'r', 't');
	vary_two(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'r', 't');

	vary_two(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'r', 'S');
	vary_two(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'r', 'S');

	vary_two(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'sig', 't');
	vary_two(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'sig', 't');

	vary_two(@C, s, t, 'C', T, K, mu, r, sig, n, m, 'sig', 'S');
	vary_two(@P, s, t, 'P', T, K, mu, r, sig, n, m, 'sig', 'S');

	vary_two(@C, s, t, 'C', T, K, mu, r, sig, n, m, 't', 'S');
	vary_two(@P, s, t, 'P', T, K, mu, r, sig, n, m, 't', 'S');
end

function simulate_paths(s, t, T, mu, sig, n, name)
	figure;

	for i = 1:10
		S = monte(s, T - t, mu, sig, n);
		plot (t:(T-t)/n:T, S, 'Color',rand(1,3));
		hold on;
	end

	title([name, 'Stock Prices vs Time']);
	xlabel('Time'); ylabel('Stock Prices');
	hold off;
	saveas(gcf, ['plots/', [name, '_Stock_Prices_vs_Time']], 'epsc');
end

function [S] = monte(s, T, mu, sig, n)
	dt = T/n;
	Norms = normrnd(mu, sig, n, 1);
	S = [s];

	for i = 2:n+1
		s = s * (1 + mu*dt + sig*(dt^0.5)*Norms(i-1));
		S = [S, s];
	end
end

function [y] = C(t, s, T, K, mu, r, sig, n, m)
	S_avg = 0;
	for i = 1:m
		S = monte(s, T-t, r, sig, n);
		S_avg = S_avg + mean(S);
	end
	S_avg = S_avg/m;
	
	y = exp(-r*(T-t)) * max(S_avg - K, 0);
end

function [y] = P(t, s, T, K, mu, r, sig, n, m)
	S_avg = 0;
	for i = 1:m
		S = monte(s, T-t, r, sig, n);
		S_avg = S_avg + mean(S);
	end
	S_avg = S_avg/m;

	y = exp(-r*(T-t)) * max(K - S_avg, 0);
end

function vary_one(V, S, t, opt, T, K, mu, r, sig, n, m, name)

	figure;
	A = []; B = [];

	if name == 'T'
		A = (0.5:0.1:1.5)*T;
		for i = 1:length(A)
			B = [B, V(t, S, A(i), K, mu, r, sig, n, m)];
		end
	elseif name == 'K'
		A = (0.5:0.1:1.5)*K;
		for i = 1:length(A)
			B = [B, V(t, S, T, A(i), mu, r, sig, n, m)];
		end
	elseif name(1) == 'm'
		A = (0.5:0.1:2)*mu;
		for i = 1:length(A)
			B = [B, V(t, S, T, K, A(i), r, sig, n, m)];
		end
	elseif name == 'r'
		A = (0.5:0.1:2)*r;
		for i = 1:length(A)
			B = [B, V(t, S, T, K, mu, A(i), sig, n, m)];
		end
	elseif name(end) == 'g'
		A = (0.5:0.1:2)*sig;
		for i = 1:length(A)
			B = [B, V(t, S, T, K, mu, r, A(i), n, m)];
		end
	elseif name == 't'
		A = 0:0.1:T;
		for i = 1:length(A)
			B = [B, V(A(i), S, T, K, mu, r, sig, n, m)];
		end
	else
		A = (0.8:0.03:1.3)*S;
		for i = 1:length(A)
			B = [B, V(t, A(i), T, K, mu, r, sig, n, m)];
		end
	end

	plot(A, B);
	tit = sprintf('Option Prices varying with %s', name);
	if opt == 'P'
		tit = ['Put ', tit];
	else
		tit = ['Call ', tit];
	end
	xlabel(name)
	ylabel('Derivative Price');
	title(tit);
	for i = 1:length(tit)
		if tit(i) == ' '
			tit(i) = '_';
		end
	end
	saveas(gcf, ['plots/', tit], 'epsc');
	hold off;

	fprintf('\n%s\n%s\tPrices\n', tit, name);
	for i = 1:length(A)
		fprintf('%f\t%f\n', A(i), B(i));
	end
end

function vary_two(V, S, t, opt, T, K, mu, r, sig, n, m, name1, name2)

	figure;
	A = []; B = []; C = [];

	if (name1 == 'r') & (name2(end) == 'sig')
		A = (0.5:0.1:2)*r;
		B = (0.5:0.1:2)*sig;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(t, S, T, K, mu, A(i), B(j), n, m)];
			end
			C = [C; temp];
		end
	elseif (name1 == 'r') & (name2 == 't')
		A = (0.5:0.1:2)*r;
		B = 0:0.1:T;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(B(j), S, T, K, mu, A(i), sig, n, m)];
			end
			C = [C; temp];
		end
	elseif (name1 == 'r') & (name2 == 'S')
		A = (0.5:0.1:2)*r;
		B = (0.5:0.1:2)*S;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(t, B(j), T, K, mu, A(i), sig, n, m)];
			end
			C = [C; temp];
		end
	elseif (name1(end) == 'sig') & (name2 == 't')
		A = (0.5:0.1:2)*sig;
		B = 0:0.1:T;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(B(j), S, T, K, mu, r, A(i), n, m)];
			end
			C = [C; temp];
		end
	elseif (name1(end) == 'sig') & (name2 == 'S')
		A = (0.5:0.1:2)*sig;
		B = (0.5:0.1:2)*S;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(t, B(j), T, K, mu, r, A(i), n, m)];
			end
			C = [C; temp];
		end
	else %t, S
		A = 0:0.1:T;
		B = (0.5:0.1:2)*S;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(A(i), B(j), T, K, mu, r, sig, n, m)];
			end
			C = [C; temp];
		end
	end

	surf(A, B, C');
	tit = sprintf('Option Prices varying with (%s, %s)', name1, name2);
	if opt == 'P'
		tit = ['Put ', tit];
	else
		tit = ['Call ', tit];
	end
	xlabel(name1);
	ylabel(name2);
	zlabel('Derivative Price');
	title(tit);
	for i = 1:length(tit)
		if tit(i) == ' '
			tit(i) = '_';
		end
	end
	saveas(gcf, ['plots/', tit], 'epsc');
	hold off;
end
