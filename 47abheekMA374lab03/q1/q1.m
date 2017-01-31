function q1
	clear; close all;
	global image_num;
	image_num = 1;
	S0 = 100;
	K = 100;
	T = 1;
	r = 0.08;
	M = 100;
	sig = 0.2;

	q1_part(S0, K, T, r, M, sig, @U2, @D2, 'S(0)');
	q1_part(S0, K, T, r, M, sig, @U2, @D2, 'K');
	q1_part(S0, K, T, r, M, sig, @U2, @D2, 'r');
	q1_part(S0, K, T, r, M, sig, @U2, @D2, 'sigma');
	q1_part(S0, K - 5, T, r, M, sig, @U2, @D2, 'M');
	q1_part(S0, K, T, r, M, sig, @U2, @D2, 'M');
	q1_part(S0, K + 5, T, r, M, sig, @U2, @D2, 'M');
end

function q1_part(S0, K, T, r, M, sig, U, D, part)
	n = 100;
	global image_num;
	
	S0_ = ones(1, n) * S0;
	K_ = ones(1, n) * K;
	r_ = ones(1, n) * r;
	sig_ = ones(1, n) * sig;
	M_ = ones(1, n) * M;

	if strcmp(part, 'S(0)')
		S0_ = S0 * (2/n:2/n:2);
		X = S0_;
	elseif strcmp(part, 'K')
		K_ = K * (2/n:2/n:2);
		X = K_;
	elseif strcmp(part, 'r')
		r_ = r * (10/n:10/n:10);
		X = r_;
	elseif strcmp(part, 'sigma')
		sig_ = sig * (2/n:2/n:2);
		X = sig_;
	else
		M_ = 1:5:n*5;
		X = M_;
	end

	fprintf('\n\nVarying %s\n', part);
	V0_put = [];
	V0_call = [];

	for i = 1:n
		S0 = S0_(i);
		K = K_(i);
		r = r_(i);
		sig = sig_(i);
		m = M_(i);

		dt = T/m;
		u = U(r, sig, dt);
		d = D(r, sig, dt);

		if d > exp(r*dt) or u < exp(r*dt)
			fprintf('Arbritage opportunity.\n')
		else
			V0_put = [V0_put, valuation(@amer_put, u, d, r, dt, S0, K, m)];
			V0_call = [V0_call, valuation(@amer_call, u, d, r, dt, S0, K, m)];
		end
	end

	fprintf('%s\t\tAmerican Call (initial price)\tAmerican Put (initial price)\n', part);
	for i = 1:n
		fprintf('%d\t\t%f\t\t\t%f\n', X(i), V0_call(i), V0_put(i));
	end

	figure; plot(X, V0_call); title(['American Call price (at time 0) vs ', part]); xlabel(part); ylabel('American Call price (at time 0)');
	saveas(gcf, sprintf('q1_%d.png', image_num)); image_num = image_num + 1;
	figure; plot(X, V0_put); title(['American Put price (at time 0) vs ', part]); xlabel(part); ylabel('American Put price (at time 0)');
	saveas(gcf, sprintf('q1_%d.png', image_num)); image_num = image_num + 1;
end

function [z] = amer_call(x, y)
	z = max(x - y, 0);
end

function [z] = amer_put(x, y)
	z = max(y - x, 0);
end

function [u] = U2(r, sig, dt)
	u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
end

function [d] = D2(r, sig, dt)
	d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);
end

function [V0, V] = valuation(VT, u, d, r, dt, S0, K, m)
	p = (exp(r*dt) - d) / (u - d);
	q = 1 - p;
	S = zeros(m + 1, m + 1);
	V = zeros(m + 1, m + 1);

	S(1, 1) = S0;
	for i = 1:m
		S(i + 1, 1) = S(i, 1) * d;
		S(i + 1, 2:i + 1) = u * S(i, 1:i);
	end

	V(m + 1, :) = VT(S(m + 1, :), K);
	for i = m:-1:1
		V(i, 1:i) = max((q*V(i+1, 1:i) + p*V(i+1, 2:i+1))/exp(r*dt), VT(S(i, 1:i), K));
	end

	V0 = V(1, 1);
end