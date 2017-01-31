function q2
	clear; close all;
	global image_num;
	image_num = 1;
	S0 = 100;
	T = 1;
	r = 0.08;
	sig = 0.2;

	q2_part1(S0, T, r, sig);
	q2_part2(S0, T, r, sig);
	q2_part3(S0, T, r, sig);
end

function q2_part1(S0, T, r, sig);
	fprintf('\n\nPart 1\n');
	M = [5, 10, 15];
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
			V0 = [V0, valuation(@lookback, u, d, r, dt, S0, S0, 0, m)];
		end
	end

	fprintf('M\t\tlookback European (initial price)\n');
	for i = 1:length(M)
		fprintf('%d\t\t%f\n', M(i), V0(i));
	end
end

function q2_part2(S0, T, r, sig);
	fprintf('\n\nPart 2\t\tM increased in steps of 1\n');
	M = 1:1:15;
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
			V0 = [V0, valuation(@lookback, u, d, r, dt, S0, S0, 0, m)];
		end
	end

	fprintf('M\t\tlookback European option (initial price)\n');
	for i = 1:length(M)
		fprintf('%d\t\t%f\n', M(i), V0(i));
	end

	figure; plot(M, V0); title('lookback European option (at time 0) vs M'); xlabel('M'); ylabel('lookback European option (at time 0)');
end

function q2_part3(S0, T, r, sig);
	m = 5;
	dt = T/m;
	u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
	d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);
	global V;

	if d > exp(r*dt) or u < exp(r*dt)
		fprintf('Arbritage opportunity.\n')
	else
		V = cell(m + 1, 1);
		V0 = valuation(@lookback, u, d, r, dt, S0, S0, 0, m);
	end

	t = 0:dt:T;
	fprintf('\n\nPart 3\t\tM = 20');
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

function [V0] = valuation(VT, u, d, r, dt, S0, M0, t, m)
	global V;

	p = (exp(r*dt) - d) / (u - d);
	q = 1 - p;

	if t == m
		V0 = VT(M0, S0);
		% V{t+1} = union(V{t+1}, [V0]);
		V{t+1} = [V{t+1}, V0];
	else
		high = valuation(VT, u, d, r, dt, S0*u, max(S0*u, M0), t+1, m);
		low = valuation(VT, u, d, r, dt, S0*d, M0, t+1, m);

		V0 = (p*high + q*low)/exp(r*dt);
		V{t+1} = [V{t+1}, V0];
	end
end