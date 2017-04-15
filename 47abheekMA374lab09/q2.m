function q2
	close all; clear;

	fprintf('Taking t = 0, as Dec-30-2016\n\n');
	r = 0.05;

	for i = 1:4
		[Maturity, Strike, CallP, PutP, StockP, name] = getData(i);

		part1(Maturity, Strike, CallP, name, 'Call');
		part1(Maturity, Strike, PutP, name, 'Put');

		VolatilityC = part2(Maturity, Strike, CallP, StockP, name, 'Call', r);
		VolatilityP = part2(Maturity, Strike, PutP, StockP, name, 'Put', r);

		part3(StockP, Maturity, VolatilityC, VolatilityP, name);
	end
end

function [y] = newton(S, K, T, price, name, r)
	if name(1) == 'C'
		V = @C;
	else
		V = @P;
	end

	x0 = 0.2; x1 = 0.5;
	while (abs(x1 - x0) > 10^(-5))
		x0 = x1;
		x1 = x0 - (V(0, S, T, K, r, x0) - price)/ dCP(0, S, T, K, r, x0);
	end

	y = x1;
end

function [y] = C(t, s, T, K, r, sig)
	d1 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r + sig^2/2)*(T-t));
	d2 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r - sig^2/2)*(T-t));
	y = s*normcdf(d1) - K*exp(-r*(T-t))*normcdf(d2);
end

function [y] = P(t, s, T, K, r, sig)
	y = C(t, s, T, K, r, sig) + K*exp(-r*(T-t)) - s;
end

function [y] = dCP(t, s, T, K, r, sig)
	d1 = (1/(sig*(T-t)^0.5)) * (log(s/K) + (r + sig^2/2)*(T-t));
	y = s * (T-t)^0.5 * normpdf(d1);
end

function part3(StockP, Maturity, VolatilityC, VolatilityP, name)
	fprintf('\n\n%s\nMaturity (working days)\t\tImplied Volatility\t\tHistorical Volatility\n', name);
	HistoricalVolatility = zeros(size(Maturity));
	ImpliedVolatility = zeros(size(Maturity));
	for i = 1:length(Maturity)
		K = StockP(end - Maturity(i): end);
		K = log(K);
		K = K(2:end) - K(1:end-1);
		HistoricalVolatility(i) = std(K) * 252^0.5;
		ImpliedVolatility(i) = (mean(VolatilityC(:, i)') + mean(VolatilityP(:, i)'))/2;
		fprintf('%d\t\t\t\t%f\t\t\t%f\n', Maturity(i), ImpliedVolatility(i), HistoricalVolatility(i));
	end

	figure;
	plot (Maturity, HistoricalVolatility, 'b'); hold on;
	plot (Maturity, ImpliedVolatility, 'r'); hold off;

	title (sprintf('%s Both Volatility vs Maturity', name));
	legend('HistoricalVolatility', 'ImpliedVolatility'); 
	xlabel('Maturity (in days)'); ylabel('Volatility');
	saveas(gcf, ['plots/', sprintf('%s_Both_Volatility_vs_Maturity', name)], 'epsc');
end

function [Volatility] = part2(Maturity, Strike, Price, StockP, name1, name2, r)
	[n, m] = size(Price);
	Volatility = zeros(n, m);
	for i = 1:n
		for j = 1:m
			Volatility(i, j) = newton(StockP(end), Strike(i), Maturity(j)/252, Price(i, j), name2, r);
		end
	end
	Volatility = slowFix(Volatility);

	figure;
	surf (Maturity, Strike, Volatility);
	title (sprintf('%s %s Volatility vs (Maturity, Strike)', name1, name2));
	xlabel('Maturity (in days)');
	ylabel('Strike');
	zlabel('Volatility');
	saveas(gcf, ['plots/', sprintf('%s_%s_Volatility_vs_(Maturity,_Strike)', name1, name2)], 'epsc');

	figure;
	label = cell(1, length(Strike));
	for i = 1:length(Strike)
		plot (Maturity, Volatility(i, :), 'Color', rand(1,3));
		label{i} = sprintf('Strike = %d', Strike(i));
		hold on;
	end
	hold off;
	title (sprintf('%s %s Volatility vs Maturity', name1, name2));
	legend(label); xlabel('Maturity (in days)');
	ylabel('Volatility');
	saveas(gcf, ['plots/', sprintf('%s_%s_Volatility_vs_Maturity', name1, name2)], 'epsc');

	figure;
	label = cell(1, length(Maturity));
	for i = 1:length(Maturity)
		plot (Strike, Volatility(:, i)', 'Color', rand(1,3));
		label{i} = sprintf('Maturity (in days) = %d', Maturity(i));
		hold on;
	end
	hold off;
	title (sprintf('%s %s Volatility vs Strike', name1, name2));
	legend(label); xlabel('Strike');
	ylabel('Volatility');
	saveas(gcf, ['plots/', sprintf('%s_%s_Volatility_vs_Strike', name1, name2)], 'epsc');
end

function part1(Maturity, Strike, Price, name1, name2)
	figure;
	surf (Maturity, Strike, Price);
	title (sprintf('%s %s Option Price vs (Maturity, Strike)', name1, name2));
	xlabel('Maturity (in days)');
	ylabel('Strike');
	zlabel('Option Price');
	saveas(gcf, ['plots/', sprintf('%s_%s_Option_Price_vs_(Maturity,_Strike)', name1, name2)], 'epsc');

	figure;
	label = cell(1, length(Strike));
	for i = 1:length(Strike)
		plot (Maturity, Price(i, :), 'Color', rand(1,3));
		label{i} = sprintf('Strike = %d', Strike(i));
		hold on;
	end
	hold off;
	title (sprintf('%s %s Option Price vs Maturity', name1, name2));
	legend(label); xlabel('Maturity (in days)');
	ylabel('Option Price');
	saveas(gcf, ['plots/', sprintf('%s_%s_Option_Price_vs_Maturity', name1, name2)], 'epsc');

	figure;
	label = cell(1, length(Maturity));
	for i = 1:length(Maturity)
		plot (Strike, Price(:, i)', 'Color', rand(1,3));
		label{i} = sprintf('Maturity (in days) = %d', Maturity(i));
		hold on;
	end
	hold off;
	title (sprintf('%s %s Option Price vs Strike', name1, name2));
	legend(label); xlabel('Strike');
	ylabel('Option Price');
	saveas(gcf, ['plots/', sprintf('%s_%s_Option_Price_vs_Strike', name1, name2)], 'epsc');
end

function [Maturity, Strike, CallP, PutP, StockP, name] = getData(a)
	StockP = flipud(csvread('data/nsedata1', 1, 0));
	if a == 1
		Maturity = (3:3:12) * 21;
		n = 3; m = 4;
		data = csvread('data/NIFTYoptiondata', 2, 1);
		StockP = StockP(:, 1)';
		name = 'NIFTY';
	else
		Maturity = (1:3) * 21;
		n = 3; m = 3;
		data = csvread('data/stockoptiondata', 2, 1);
		data = data(1:end, (a-1)*3 - 2 : (a-1)*3);
		if a == 2
			name = 'AMBUJACEM';
			StockP = StockP(:, 3)';
		elseif a == 3
			name = 'BAJAJ-AUTO';
			StockP = StockP(:, 5)';
		else
			name = 'BANKBARODA';
			StockP = StockP(:, 10)';
		end
	end

	Strike = zeros(1, n);
	CallP = zeros(n, m);

	for i = 1:n
		Strike(i) = data(i*m, 1);
		for j = 1:m
			CallP(i, j) = data( (i-1)*m + j , 2);
			PutP(i, j) = data( (i-1)*m + j , 3);
		end
	end
end

function [y] = slowFix(A)
	A(isnan(A)) = 0.15;
	for i = 1:size(A, 1)
		B = A(:, i)';
		B(B == 0.15) = mean(B);
		A(:, i) = B';
	end
	y = A;
end