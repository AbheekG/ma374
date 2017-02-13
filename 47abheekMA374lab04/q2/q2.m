function q1
	clear; close all;

	[m, C] = setup_data();
	r = 0.07;

	syms x;
	[f(x), g(x)] = weights(x, m, C);
	[h(x), w_m, mu_m, sig_m] = capm(x, m, C, r);
	
	q1_part1(g);
	q1_part2(f, g, h, w_m, mu_m, sig_m);
	q1_part4(f, g, h, w_m, mu_m, sig_m, r, m, C);

end

function [m, C] = setup_data()
	data = csvread('data.csv', 1, 1);
	data = flipud(data);
	[l, b] = size(data);
	% ret = zeros(l, b);
	A = ones(l, 2);
	A(:, 2) = 1:l;

	m = zeros(1, b);
	C = zeros(b, b);

	for i = 1:b
		x = A\data(:, i);
		% figure; plot(A(:, 2), data(:, i), A(:, 2), A*x)
		m(i) = x(2)*365/(7*x(1));
		% ret(:, i) = (365/7)*(data(:, i) - A*x)./(A*x);
	end
	% C = cov(ret)
	C = cov((365/7)*(data(2:end, :) - data(1:end-1, :))./data(1:end-1, :));
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
	mu = -0.3:0.01:0.5;
	sig = zeros(size(mu));
	for i = 1:length(sig)
		sig(i) = g(mu(i));
	end

	plot(sig, mu);
	title('Return vs Risk'); xlabel('Risk'); ylabel('Return');
	legend('Efficient Frontier');
end

function q1_part2(f, g, h, w_m, mu_m, sig_m)
	fprintf('\nMarket Portfolio\nWeights\t\t\t\t\tReturn\t\tRisk\n')
	fprintf('[')
	for j = 1:length(w_m)
		fprintf('%f, ', double(w_m(j)));
	end
	fprintf(']\t%f\t%f\n', mu_m, double(sig_m));

	mu = -1:0.01:2;
	sig = zeros(size(mu));
	for i = 1:length(sig)
		sig(i) = g(mu(i));
	end
	% figure; plot(X, V0_call); title(['European Call price (at time 0) vs ', part]); xlabel(part); ylabel('European Call price (at time 0)');
	% saveas(gcf, sprintf('q1_%d.png', image_num)); image_num = image_num + 1;
	figure; plot(sig, mu); hold on;
	title('Return vs Risk'); xlabel('Risk'); ylabel('Return');

	sig = 0:0.01:3.5;
	plot(sig, h(sig));
	legend('Efficient frontier', 'Capital Market Line');
end

function q1_part4(f, g, h, w_m, mu_m, sig_m, r, m ,C)
	image_num = 3;
	bet = -1:0.1:2;
	mu = r + (mu_m - r)*bet;
	figure; plot(bet, mu);hold on;
	title('Security Market line'); xlabel('Beta'); ylabel('Return');

	for i = 1:10
		bet = (C(i, :)*w_m')/C(i, i);
		mu = m(i);
		hold on; plot(bet, mu, 'ro'); 
	end

	hold off;
	saveas(gcf, sprintf('plot%d.jpg', image_num)); image_num = image_num + 1;

	mu = -1:0.01:2;
	sig = zeros(size(mu));
	for i = 1:length(sig)
		sig(i) = g(mu(i));
	end
	% figure; plot(X, V0_call); title(['European Call price (at time 0) vs ', part]); xlabel(part); ylabel('European Call price (at time 0)');
	% saveas(gcf, sprintf('q1_%d.png', image_num)); image_num = image_num + 1;
	figure; plot(sig, mu); hold on;
	title('Lines for all the individual stocks'); xlabel('Risk'); ylabel('Return');

	sig = 0:0.01:3.5;
	plot(sig, h(sig)); hold on;
	for i = 1:10
		a = [0, C(i, i)^(0.5)];
		b = [r, mu(i)];
		plot (a, b);
	end
	saveas(gcf, sprintf('plot%d.jpg', image_num)); image_num = image_num + 1;
	% figure; plot(sig, mu); hold on;
	% title('Return vs Risk'); xlabel('Risk'); ylabel('Return');

	% sig = 0:0.01:3.5;
	% plot(sig, h(sig));
	% legend('Efficient frontier', 'Capital Market Line');
end