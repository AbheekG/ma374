function q1
	clear; close all;
	S0 = 9;
	K = 10;
	T = 3;
	r = 0.06;
	sig = 0.3;

	q1_part1(S0, K, T, r, sig);
	q1_part2a(S0, K, T, r, sig);
	q1_part2b(S0, K, T, r, sig);
	q1_part3(S0, K, T, r, sig);
end

function q1_part1(S0, K, T, r, sig);
	fprintf('\n\nPart 1\n');
	M = [1, 5, 10, 20, 50, 100, 200, 400];
	V0_put = [];
	V0_call = [];

	for i = 1:length(M)
		m = M(i);
		dt = T/m;
		u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
		d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);

		if d > exp(r*dt) or u < exp(r*dt)
			fprintf('Arbritage opportunity.\n')
		else
			V0_put = [V0_put, valuation(@euro_put, u, d, r, dt, S0, K, m)];
			V0_call = [V0_call, valuation(@euro_call, u, d, r, dt, S0, K, m)];
		end
	end

	fprintf('M\t\tEuropean Call (initial price)\tEuropean Put (initial price)\n');
	for i = 1:length(M)
		fprintf('%d\t\t%f\t\t\t%f\n', M(i), V0_call(i), V0_put(i));
	end
end

function q1_part2a(S0, K, T, r, sig);
	fprintf('\n\nPart 2a\t\tM increased in steps of 1\n');
	M = 1:1:40;
	V0_put = [];
	V0_call = [];

	for i = 1:length(M)
		m = M(i);
		dt = T/m;
		u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
		d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);

		if d > exp(r*dt) or u < exp(r*dt)
			fprintf('Arbritage opportunity.\n')
		else
			V0_put = [V0_put, valuation(@euro_put, u, d, r, dt, S0, K, m)];
			V0_call = [V0_call, valuation(@euro_call, u, d, r, dt, S0, K, m)];
		end
	end

	fprintf('M\t\tEuropean Call (initial price)\tEuropean Put (initial price)\n');
	for i = 1:length(M)
		fprintf('%d\t\t%f\t\t\t%f\n', M(i), V0_call(i), V0_put(i));
	end

	figure; plot(M, V0_call); title('European Call (at time 0) vs M'); xlabel('M'); ylabel('European Call (at time 0)');
	figure; plot(M, V0_put); title('European Put (at time 0) vs M'); xlabel('M'); ylabel('European Put (at time 0)');
end

function q1_part2b(S0, K, T, r, sig);
	fprintf('\n\nPart 2b\t\tM increased in steps of 5\n');
	M = 1:5:200;
	V0_put = [];
	V0_call = [];

	for i = 1:length(M)
		m = M(i);
		dt = T/m;
		u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
		d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);

		if d > exp(r*dt) or u < exp(r*dt)
			fprintf('Arbritage opportunity.\n')
		else
			V0_put = [V0_put, valuation(@euro_put, u, d, r, dt, S0, K, m)];
			V0_call = [V0_call, valuation(@euro_call, u, d, r, dt, S0, K, m)];
		end
	end

	fprintf('M\t\tEuropean Call (initial price)\tEuropean Put (initial price)\n');
	for i = 1:length(M)
		fprintf('%d\t\t%f\t\t\t%f\n', M(i), V0_call(i), V0_put(i));
	end

	figure; plot(M, V0_call); title('European Call (at time 0) vs M'); xlabel('M'); ylabel('European Call (at time 0)');
	figure; plot(M, V0_put); title('European Put (at time 0) vs M'); xlabel('M'); ylabel('European Put (at time 0)');
end

function q1_part3(S0, K, T, r, sig);
	m = 20;
	dt = T/m;
	u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
	d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);

	if d > exp(r*dt) or u < exp(r*dt)
		fprintf('Arbritage opportunity.\n')
	else
		[temp, V0_put] = valuation(@euro_put, u, d, r, dt, S0, K, m);
		[temp, V0_call] = valuation(@euro_call, u, d, r, dt, S0, K, m);
	end

	t = [0, 0.30, 0.75, 1.50, 2.70];
	fprintf('\n\nPart 3\t\tM = 20');
	fprintf('\nt (time)\tEuropean Call values at time t');
	for i = 1:length(t)
		fprintf('\n%f\t', t(i));
		for j = 1:(t(i)*m/T + 1)
			fprintf('%f ', V0_call(t(i)*m/T + 1, j));
		end
	end

	fprintf('\nt (time)\tEuropean Put values at time t');
	for i = 1:length(t)
		fprintf('\n%f\t', t(i));
		for j = 1:(t(i)*m/T + 1)
			fprintf('%f ', V0_put(t(i)*m/T + 1, j));
		end
	end
end

function [z] = euro_call(x, y)
	z = max(x - y, 0);
end

function [z] = euro_put(x, y)
	z = max(y - x, 0);
end

function [V0, V] = valuation(VT, u, d, r, dt, S0, K, m)
	p = (exp(r*dt) - d) / (u - d);
	q = 1 - p;
	V = zeros(m + 1, m + 1);

	V(m + 1, :) = VT(S0 .* u.^(0:m) .* d.^(m:-1:0), K);
	for i = m:-1:1
		V(i, 1:i) = (q*V(i+1, 1:i) + p*V(i+1, 2:i+1))/exp(r*dt);
	end

	V0 = V(1, 1);
end