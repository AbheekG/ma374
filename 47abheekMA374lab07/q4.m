function q2
	close all; clear;
	'Original Paramaters'
	T = 1
	K = 1
	r = 0.05
	sig = 0.6
	t = 0
	s = 1
	% T = 1;
	% K = 1;
	% r = 0.05;
	% sig = 0.6;
	% t = 0;
	% s = 1;

	vary_one(@C, s, t, 'C', T, K, r, sig, 'T');
	vary_one(@P, s, t, 'P', T, K, r, sig, 'T');

	vary_one(@C, s, t, 'C', T, K, r, sig, 'K');
	vary_one(@P, s, t, 'P', T, K, r, sig, 'K');

	vary_one(@C, s, t, 'C', T, K, r, sig, 'r');
	vary_one(@P, s, t, 'P', T, K, r, sig, 'r');
	
	vary_one(@C, s, t, 'C', T, K, r, sig, 'sig');
	vary_one(@P, s, t, 'P', T, K, r, sig, 'sig');

	vary_one(@C, s, t, 'C', T, K, r, sig, 't');
	vary_one(@P, s, t, 'P', T, K, r, sig, 't');

	vary_one(@C, s, t, 'C', T, K, r, sig, 'S');
	vary_one(@P, s, t, 'P', T, K, r, sig, 'S');

	% Doing for r, sig, t, S
	vary_two(@C, s, t, 'C', T, K, r, sig, 'r', 'sig');
	vary_two(@P, s, t, 'P', T, K, r, sig, 'r', 'sig');
	
	vary_two(@C, s, t, 'C', T, K, r, sig, 'r', 't');
	vary_two(@P, s, t, 'P', T, K, r, sig, 'r', 't');

	vary_two(@C, s, t, 'C', T, K, r, sig, 'r', 'S');
	vary_two(@P, s, t, 'P', T, K, r, sig, 'r', 'S');

	vary_two(@C, s, t, 'C', T, K, r, sig, 'sig', 't');
	vary_two(@P, s, t, 'P', T, K, r, sig, 'sig', 't');

	vary_two(@C, s, t, 'C', T, K, r, sig, 'sig', 'S');
	vary_two(@P, s, t, 'P', T, K, r, sig, 'sig', 'S');

	vary_two(@C, s, t, 'C', T, K, r, sig, 't', 'S');
	vary_two(@P, s, t, 'P', T, K, r, sig, 't', 'S');
end

function [y] = C(t, s, T, K, r, sig)
	d1 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r + sig^2/2)*(T-t));
	d2 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r - sig^2/2)*(T-t));
	y = s*normcdf(d1) - K*exp(-r*(T-t))*normcdf(d2);
end

function [y] = P(t, s, T, K, r, sig)
	y = C(t, s, T, K, r, sig) + K*exp(-r*(T-t)) - s;
end

function vary_one(V, S, t, opt, T, K, r, sig, name)

	figure;
	A = []; B = [];

	if name == 'T'
		A = 0.2:0.2:2;
		for i = 1:length(A)
			B = [B, V(t, S, A(i), K, r, sig)];
		end
	elseif name == 'K'
		A = 0.5:0.1:1.5;
		for i = 1:length(A)
			B = [B, V(t, S, T, A(i), r, sig)];
		end
	elseif name == 'r'
		A = 0.02:0.02:0.2;
		for i = 1:length(A)
			B = [B, V(t, S, T, K, A(i), sig)];
		end
	elseif name == 'sig'
		A = 0.2:0.1:1;
		for i = 1:length(A)
			B = [B, V(t, S, T, K, r, A(i))];
		end
	elseif name == 't'
		A = 0:0.1:1;
		for i = 1:length(A)
			B = [B, V(A(i), S, T, K, r, sig)];
		end
	else
		A = 0.2:0.2:2;
		for i = 1:length(A)
			B = [B, V(t, A(i), T, K, r, sig)];
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
	saveas(gcf, ['plot/', tit], 'epsc');
	hold off;

	fprintf('\n%s\n%s\tPrices\n', tit, name);
	for i = 1:length(A)
		fprintf('%f\t%f\n', A(i), B(i));
	end
end

function vary_two(V, S, t, opt, T, K, r, sig, name1, name2)

	figure;
	A = []; B = []; C = [];

	if (name1 == 'r') & (name2 == 'sig')
		A = 0.02:0.02:0.2;
		B = 0.2:0.1:1; 
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(t, S, T, K, A(i), B(j))];
			end
			C = [C; temp];
		end
	elseif (name1 == 'r') & (name2 == 't')
		A = 0.02:0.02:0.2;
		B = 0:0.1:1;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(B(j), S, T, K, A(i), sig)];
			end
			C = [C; temp];
		end
	elseif (name1 == 'r') & (name2 == 'S')
		A = 0.02:0.02:0.2;
		B = 0.2:0.2:2;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(t, B(j), T, K, A(i), sig)];
			end
			C = [C; temp];
		end
	elseif (name1 == 'sig') & (name2 == 't')
		A = 0.2:0.1:1;
		B = 0:0.1:1;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(B(j), S, T, K, r, A(i))];
			end
			C = [C; temp];
		end
	elseif (name1 == 'sig') & (name2 == 'S')
		A = 0.2:0.1:1;
		B = 0.2:0.2:2;
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(t, B(j), T, K, r, A(i))];
			end
			C = [C; temp];
		end
	else %t, S
		A = 0:0.1:1;
		B = 0.2:0.2:2; 
		for i = 1:length(A)
			temp = [];
			for j = 1:length(B)
				temp = [temp, V(A(i), B(j), T, K, r, sig)];
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
	saveas(gcf, ['plot/', tit], 'epsc');
	hold off;
end
