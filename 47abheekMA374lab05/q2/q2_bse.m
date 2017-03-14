function q2_bse
	clear; close all;

	[mu_m, sig_m, m, C] = setup_data();
	r = 0.05;

	syms x;
	[f(x), g(x)] = weights(x, m(1:10), C(1:10, 1:10));
	h(x) = capm(x, mu_m, sig_m(1)^0.5, r);
	
	q1_part1(g);
	q1_part2(f, g, h, mu_m, sig_m(1)^0.5);
	q1_part3(f, g, h, mu_m, sig_m, r, m, C);

end

function [mu_m, sig_m, m, C] = setup_data()
	dat1 = csvread('bsedata1', 1, 0);
	dat2 = csvread('nonindexdata1');
	data = [dat1, dat2];
	data = flipud(data);
	[l, b] = size(data);

	R = log(data);
	R = R(2:end, :) - R(1:end-1, :);

	m = mean(R)*l/5;
	C = cov(R)*l/5;

	mu_m = m(1);
	m = m(2:end);
	sig_m = C(1, :);
	C = C(2:end, 2:end);
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

function h = capm(x, mu_m, sig_m, r)
	h(x) = (mu_m - r)*x/sig_m + r;
end

function q1_part1(g)
	mu = -0.1:0.01:0.2;
	sig = zeros(size(mu));
	for i = 1:length(sig)
		sig(i) = g(mu(i));
	end

	figure; plot(sig, mu);
	title('Return vs Risk'); xlabel('Risk'); ylabel('Return');
	legend('Minimum Variance Line');

	[temp, temp] = min(sig);
	figure; plot(sig(temp:end), mu(temp:end));
	title('Return vs Risk'); xlabel('Risk'); ylabel('Return');
	legend('Efficient Frontier');
end

function q1_part2(f, g, h, mu_m, sig_m)
	fprintf('\nIndex Portfolio\nReturn = %f, Risk = %f\n', mu_m, double(sig_m));

	mu = -01:0.1:2;
	sig = zeros(size(mu));
	for i = 1:length(sig)
		sig(i) = g(mu(i));
	end

	figure; plot(sig, mu); hold on;
	title('Return vs Risk'); xlabel('Risk'); ylabel('Return');

	sig = 0:0.01:1;
	plot(sig, h(sig)); plot(sig_m, mu_m, 'o')
	legend('Minimum Variance Line', 'Capital Market Line');
end

function q1_part3(f, g, h, mu_m, sig_m, r, m ,C)
	image_num = 3;
	bet = -1:0.1:2;
	mu = r + (mu_m - r)*bet;
	figure; plot(bet, mu);hold on;
	title('Security Market line'); xlabel('Beta'); ylabel('Return');

	fprintf('Stock\t\t\tCalculated Beta\tExpected Return (CAPM)\tActual Return\tOverpriced\n');
	for i = 1:20
		bet = sig_m(i+1)/sig_m(1);
		mu = m(i);
		if i > 10
			fprintf('Stock %d (Outside index)\t\t', mod(i, 10));
		else
			fprintf('Stock %d (In index)\t\t', mod(i, 10));				
		end
		if r + (mu_m - r)*bet > mu
			overp = 'Yes';
			col = 'ro';
		else
			overp = 'No';
			col = 'bo';
		end
		fprintf('%f\t\n', bet);
		% fprintf('%f\t%f\t%f\t%s\n', bet, r + (mu_m - r)*bet, mu, overp);
		hold on; plot(bet, mu, col); 
	end

	% mu = -1:0.01:2;
	% sig = zeros(size(mu));
	% for i = 1:length(sig)
	% 	sig(i) = g(mu(i));
	% end

	% figure; plot(sig, mu); hold on;
	% title('Lines for all the individual stocks'); xlabel('Risk'); ylabel('Return');

	% sig = 0:0.01:3.5;
	% plot(sig, h(sig)); hold on;
	% for i = 1:10
	% 	a = [0, C(i, i)^(0.5)];
	% 	b = [r, mu(i)];
	% 	plot (a, b);
	% end
	% saveas(gcf, sprintf('plot%d.jpg', image_num)); image_num = image_num + 1;
end