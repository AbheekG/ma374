function q1
	clear; close all;

	m = [0.1, 0.2, 0.15];
	C = [0.005, -0.010, 0.004; -0.010, 0.040, -0.002; 0.004, -0.002, 0.023];
	r = 0.1;

	syms x;
	
	data = mean_var(m, C);

	n = 1000;
	sig = data(:, 1);
	mu = data(:, 2);
	figure; plot(sig, mu, 'y');
	title('Return vs Risk'); xlabel('Risk'); ylabel('Return');
	hold on;

	[sig_min, temp] = min(sig);
	mu_min = mu(temp);	data = sortrows([mu, sig, data(:, 3:5)]);
	mu = data(:, 1);
	sig = data(:, 2);
	d = [];
	tol = 1/n;
	a = 0; b = 0;

	for i = 1:length(mu)
		a = mu(i);
		b = sig(i);
		while (i <= length(mu) && mu(i) < tol + a)
			if (sig(i) < b)
				b = sig(i);
				c = data(i, :);
			end
			i = i + 1;
		end
		d = [d; c];
	end
	plot(d(:, 2), d(:, 1), 'b.-'); hold on;

	temp = d(:, 1) >= mu_min;
	plot(d(temp, 2), d(temp, 1), 'r.-'); hold on;

	temp = data(:, 5) == 0;
	plot(data(temp, 2), data(temp, 1), 'c.-'); hold on;

	temp = data(:, 4) == 0;
	plot(data(temp, 2), data(temp, 1), 'm.-'); hold on;

	temp = data(:, 3) == 0;
	plot(data(temp, 2), data(temp, 1), 'g.-'); hold on;


	legend('Feasible Region', 'Minimum Variance Curve', 'Efficient Frontier', ...
		'Minimum Variance Curve for 1 and 2', 'Minimum Variance Curve for 1 and 3', ...
		'Minimum Variance Curve for 2 and 3' )
	hold off;

	figure; plot3(d(:, 3), d(:, 4), d(:, 5), '.-');
	title('Weights corresponding to Minimum Variance Curve');
	xlabel('Weight 1'); ylabel('Weight 2'); zlabel('Weight 3');
end

function [data] = mean_var(m, C)
	n = 300;
	data = [];

	i = 0;
	w = zeros(1, 3);
	for a = 0:1/n:1
		for b = 0:1/n:1-a
			w(1) = a;
			w(2) = b;
			w(3) = 1 - a - b;
			i = i + 1;
			d = zeros(1, 5);
			d(3) = w(1);
			d(4) = w(2);
			d(5) = w(3);
			d(1) = (w*C*w')^0.5;
			d(2) = w*m';
			data = [data; d];
		end
	end
end


% function [w, sig] = weights(x, m, C)
% 	function [sig] = fun(w)
% 		sig = w*C*w';
% 	end

% 	w = zeros(size(m));
% 	w(1, 1) = 1;
% 	w = fmincon(@fun, w, -eye(size(m, 2)), zeros(size(m, 2), 1), [ones(size(m)); m], [1, x]);
% 	w

% 	sig = (w*C*w')^0.5;
% end

% function [h, w, mu_m, sig_m] = capm(x, m, C, r)
% 	tic
% 	u = ones(size(m));

% 	Cinv = pinv(C);
% 	w = (m - r*u) * Cinv;
% 	w = w / sum(w);
% 	w

% 	function [val] = fun(w)
% 		val = (m * w' - r) / (w*C*w')^0.5;
% 	end

% 	w = fmincon(@fun, w, -eye(size(m, 2)), zeros(size(m, 2), 1), ones(size(m)), [1]);
	
% 	mu_m = m * w';
% 	sig_m = (w*C*w')^0.5;

% 	h(x) = (mu_m - r)*x/sig_m + r;
% end