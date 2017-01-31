% In this question we are suing Asian option with discounted average valuation
function q2
	clear; close all;
	global image_num;
	image_num = 1;
	S0 = 100;
	K = 100;
	T = 1;
	r = 0.08;
	M = 10;
	sig = 0.2;

	% Set 1
	fprintf('\n\nSet 1\n');
	q2_part(S0, K, T, r, M, sig, @U1, @D1, 'S(0)');
	q2_part(S0, K, T, r, M, sig, @U1, @D1, 'K');
	q2_part(S0, K, T, r, M, sig, @U1, @D1, 'r');
	q2_part(S0, K, T, r, M, sig, @U1, @D1, 'sigma');
	q2_part(S0, K - 5, T, r, M, sig, @U1, @D1, 'M');
	q2_part(S0, K, T, r, M, sig, @U1, @D1, 'M');
	q2_part(S0, K + 5, T, r, M, sig, @U1, @D1, 'M');

	% Set 2
	fprintf('\n\nSet 2\n');
	q2_part(S0, K, T, r, M, sig, @U2, @D2, 'S(0)');
	q2_part(S0, K, T, r, M, sig, @U2, @D2, 'K');
	q2_part(S0, K, T, r, M, sig, @U2, @D2, 'r');
	q2_part(S0, K, T, r, M, sig, @U2, @D2, 'sigma');
	q2_part(S0, K - 5, T, r, M, sig, @U2, @D2, 'M');
	q2_part(S0, K, T, r, M, sig, @U2, @D2, 'M');
	q2_part(S0, K + 5, T, r, M, sig, @U2, @D2, 'M');
end

function q2_part(S0, K, T, r, M, sig, U, D, part)
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
		M_ = 1:1:10;
		n = 10;
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
			V0_put = [V0_put, valuation(@asian_put, u, d, r, dt, S0, K, 0, m, 0)];
			V0_call = [V0_call, valuation(@asian_call, u, d, r, dt, S0, K, 0, m, 0)];
		end
	end

	fprintf('%s\t\tAsian Call (initial price)\tAsian Put (initial price)\n', part);
	for i = 1:n
		fprintf('%d\t\t%f\t\t\t%f\n', X(i), V0_call(i), V0_put(i));
	end

	figure; plot(X, V0_call); title(['Asian Call price (at time 0) vs ', part]); xlabel(part); ylabel('Asian Call price (at time 0)');
	saveas(gcf, sprintf('q2_%d.png', image_num)); image_num = image_num + 1;
	figure; plot(X, V0_put); title(['Asian Put price (at time 0) vs ', part]); xlabel(part); ylabel('Asian Put price (at time 0)');
	saveas(gcf, sprintf('q2_%d.png', image_num)); image_num = image_num + 1;
end

function [z] = asian_call(x, y)
	z = max(x - y, 0);
end

function [z] = asian_put(x, y)
	z = max(y - x, 0);
end

function [u] = U1(r, sig, dt)
	u = exp(sig * dt^0.5);
end

function [d] = D1(r, sig, dt)
	d = exp(-sig * dt^0.5);
end

function [u] = U2(r, sig, dt)
	u = exp(sig * dt^0.5 + (r - sig^2/2)*dt);
end

function [d] = D2(r, sig, dt)
	d = exp(-sig * dt^0.5 + (r - sig^2/2)*dt);
end

function [V0] = valuation(VT, u, d, r, dt, S0, K, t, m, s)
	s = s*exp(r*dt) + S0;
	p = (exp(r*dt) - d) / (u - d);
	q = 1 - p;

	if t == m
		V0 = VT(s/(m+1), K);
	else
		V0 = (p*valuation(VT, u, d, r, dt, S0*u, K, t+1, m, s) + q*valuation(VT, u, d, r, dt, S0*d, K, t+1, m, s))/exp(r*dt);
	end
end