function q1
	clear; close all;

	m = [0.1, 0.2, 0.15];
	C = [0.005, -0.010, 0.004; -0.010, 0.040, -0.002; 0.004, -0.002, 0.023];
	r = 0.1;

	syms x;
	[f(x), g(x)] = weights(x, m, C);
	[h(x), w_m, mu_m, sig_m] = capm(x, m, C, r);
	
	q1_part1(g);
	q1_part2(f, g);
	q1_part3(f, g, 0.15);
	q1_part4(f, g, 0.18);
	q1_part5(f, g, h, w_m, mu_m, sig_m);

end

function [w, sig] = weights(x, m, C)
	M = zeros(2, 2);
	u = ones(size(m));

	Cinv = pinv(C);
	M(1, 1) = m * Cinv * m';
	M(1, 2) = u * Cinv * m';
	M(2, 1) = m * Cinv * u';
	M(2, 2) = u * Cinv * u';

	lamda = pinv(M) * [x; 1];

	w = (lamda(1)*m + lamda(2)*u) * Cinv;

	sig = (w*C*w')^0.5;
end

function [h, w, mu_m, sig_m] = capm(x, m, C, r)
	u = ones(size(m));

	Cinv = pinv(C);
	w = (m - r*u) * Cinv;
	w = w / sum(w);

	mu_m = m * w';
	sig_m = (w*C*w')^0.5;

	h(x) = (mu_m - r)*x/sig_m + r;
end


function q1_part1(g)
	mu = 0:0.001:0.2;
	sig = zeros(size(mu));
	for i = 1:length(sig)
		sig(i) = g(mu(i));
	end

	plot(sig, mu);
end

function q1_part2(f, g)
	mu = 0:0.03:0.27;

	fprintf('\n\nWeights\t\t\t\t\tReturn\t\tRisk\n')
	for i = 1:10
		w = f(mu(i));
		sig = g(mu(i));
		fprintf('[')
		for j = 1:length(w)
			fprintf('%f, ', double(w(j)));
		end
		fprintf(']\t%f\t%f\n', mu(i), double(sig));
	end
end

function q1_part3(f, g, sig)
	% m = [0, 0];

	l = 0.15;
	r = 0.2;
	while (abs(l - r) > 1e-7)
		m(1) = (l + r)/2;
		if (g(m(1)) > sig)
			r = m(1);
		else
			l = m(1);
		end
	end

	l = 0;
	r = 0.1;
	while (abs(l - r) > 1e-7)
		m(2) = (l + r)/2;
		if (g(m(2)) > sig)
			l = m(2);
		else
			r = m(2);
		end
	end

	fprintf('\nMaximum and Minimum Return Portfolio')
	for i = 1:2
		fprintf('\nWeights\t\t\t\t\tReturn\t\tRisk\n')
		mu = m(i);
		w = f(mu);
		sig = g(mu);
		fprintf('[')
		for j = 1:length(w)
			fprintf('%f, ', double(w(j)));
		end
		fprintf(']\t%f\t%f\n', mu, double(sig));
	end
end

function q1_part4(f, g, mu)
	fprintf('\nMinimum Risk Portfolio\nWeights\t\t\t\t\tReturn\t\tRisk\n')
	
	w = f(mu);
	sig = g(mu);
	fprintf('[')
	for j = 1:length(w)
		fprintf('%f, ', double(w(j)));
	end
	fprintf(']\t%f\t%f\n', mu, double(sig));
end

function q1_part5(f, g, h, w_m, mu_m, sig_m)
	fprintf('\nMarket Portfolio\nWeights\t\t\t\t\tReturn\t\tRisk\n')
	fprintf('[')
	for j = 1:length(w_m)
		fprintf('%f, ', double(w_m(j)));
	end
	fprintf(']\t%f\t%f\n', mu_m, double(sig_m));

	mu = 0:0.001:0.2;
	sig = zeros(size(mu));
	for i = 1:length(sig)
		sig(i) = g(mu(i));
	end
	% figure; plot(X, V0_call); title(['European Call price (at time 0) vs ', part]); xlabel(part); ylabel('European Call price (at time 0)');
	% saveas(gcf, sprintf('q1_%d.png', image_num)); image_num = image_num + 1;
	figure; plot(sig, mu); hold on;

	sig = 0:0.001:0.17;
	h(1);
	plot(sig, h(sig));
end

function q1_part6(w_m, mu_m, sig_m)
	fprintf('\nMixed Portfolio with Risk 10%\nWeights\t\t\t\t\tReturn\t\tRisk\n')
	fprintf('[')
	for j = 1:length(w_m)
		fprintf('%f, ', double(w_m(j)));
	end
	fprintf(']\t%f\t%f\n', mu_m, double(sig_m));

	mu = 0:0.001:0.2;
	sig = zeros(size(mu));
	for i = 1:length(sig)
		sig(i) = g(mu(i));
	end
	% figure; plot(X, V0_call); title(['European Call price (at time 0) vs ', part]); xlabel(part); ylabel('European Call price (at time 0)');
	% saveas(gcf, sprintf('q1_%d.png', image_num)); image_num = image_num + 1;
	figure; plot(sig, mu); hold on;

	sig = 0:0.001:0.17;
	h(1);
	plot(sig, h(sig));
end