function q3
	clear; close all;
	global image_num;
	image_num = 1;
	S0 = 100;
	T = 1;
	r = 0.08;
	sig = 0.2;

	q3_part1(S0, T, r, sig);
	q3_part2(S0, T, r, sig);
	q3_part3(S0, T, r, sig);
end

function q3_part1(S0, T, r, sig);
	fprintf('\n\nPart 1\n');
	M = [5, 10, 15, 20, 25, 30];
	V0 = [];
	global V;

	for i = 1:length(M)
		m = M(i);
		dt = T/m;
		u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
		d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);

		if d > exp(r*dt) or u < exp(r*dt)
			fprintf('Arbritage opportunity.\n')
		else
			V = cell(m + 1, 1);
			V0 = [V0, valuation(@lookback, u, d, r, dt, S0, S0, m)];
		end
	end

	fprintf('M\t\tlookback European (initial price)\n');
	for i = 1:length(M)
		fprintf('%d\t\t%f\n', M(i), V0(i));
	end
end

function q3_part2(S0, T, r, sig);
	fprintf('\n\nPart 2\t\tM increased in steps of 1\n');
	M = 1:2:25;
	V0 = [];
	global V;

	for i = 1:length(M)
		m = M(i);
		dt = T/m;
		u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
		d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);

		if d > exp(r*dt) or u < exp(r*dt)
			fprintf('Arbritage opportunity.\n')
		else
			V = cell(m + 1, 1);
			V0 = [V0, valuation(@lookback, u, d, r, dt, S0, S0, m)];
		end
	end

	fprintf('M\t\tlookback European option (initial price)\n');
	for i = 1:length(M)
		fprintf('%d\t\t%f\n', M(i), V0(i));
	end

	figure; plot(M, V0); title('lookback European option (at time 0) vs M'); xlabel('M'); ylabel('lookback European option (at time 0)');
end

function q3_part3(S0, T, r, sig);
	m = 5;
	dt = T/m;
	u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
	d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);
	global V;

	if d > exp(r*dt) or u < exp(r*dt)
		fprintf('Arbritage opportunity.\n')
	else
		V = cell(m + 1, 1);
		V0 = valuation(@lookback, u, d, r, dt, S0, S0, m);
	end

	t = 0:dt:T;
	fprintf('\n\nPart 3\t\tM = 5');
	fprintf('\nt (time)\tLookback option values at time t');
	for i = 1:length(t)
		fprintf('\n%f\t', t(i));
		V0 = unique(V{i});
		for j = 1:length(V0)
			fprintf('%f ', V0(j));
		end
	end
end

function [z] = lookback(m, s)
	z = m - s;
end

function [V0] = valuation(VT, u, d, r, dt, S0, M0, m)
	global V;
	prec = 10;

	p = (exp(r*dt) - d) / (u - d);
	q = 1 - p;

	S = cell(m + 1, 1);
	S{1} = [S0; M0];

	for i = 1:m
		temp = S{i}(1, :)*u;
		temp = [temp; max([temp; S{i}(2, :)], [], 1)];
		S{i+1} = [[S{i}(1, :)*d; S{i}(2, :)], temp];
		% S{i+1} = round(S{i+1}* 10^prec)/10^prec;
		S{i+1} = unique(S{i+1}', 'rows')';
	end

	V{m+1} = VT(S{m+1}(2, :), S{m+1}(1, :));
	for i = m:-1:1
		temp1 = cell(1, length(V{i+1}));
		for j = 1:length(temp1)
			temp1{j} = mat2str(S{i+1}(:, j), prec);
		end
		map = containers.Map(temp1, V{i+1});
		V{i} = [];
		for j = 1:length(S{i}(1, :))
			% i, j, mat2str([S{i}(1, j)*u; max(S{i}(1, j)*u, S{i}(2, j))], prec)
			high = map( mat2str([S{i}(1, j)*u; max(S{i}(1, j)*u, S{i}(2, j))], prec));
			low = map( mat2str([S{i}(1, j)*d; S{i}(2, j)], prec) );
			V{i} = [V{i}, (p*high + q*low)/exp(r*dt)];
		end
	end
	V0 = V{1};
end