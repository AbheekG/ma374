function q1
	clear; close all;

	data = {flipud(csvread('bsedata1', 1, 0)), ...
			flipud(csvread('nsedata1', 1, 0)), ...
			flipud(csvread('nonindexdata1', 1, 0))};

	part1(data);

end

function [] = part1(data)
	global image_num;
	for i = 1:3
		for j = 1:3
			[len, bre] = size(data{j});
			if j == 1
				name = 'BSE ';
			elseif j == 2
				name = 'NSE ';
			else
				name = 'Non-Index ';
			end

			for k = 1:bre
				if k == 1 && j ~= 3
					name2 = 'Index';
				elseif j == 3
					name2 = ['Stock', int2str(k)];
				else
					name2 = ['Stock', int2str(k - 1)];
				end
				if i == 1
					id = 1:len;
					period = 'Daily';
					bins = 50;
				elseif i == 2
					id = 1:5:len;
					period = 'Weekly';
					bins = 20;
				else
					id = 1:int64(len/60):len;
					period = 'Monthly';
					bins = 10;
				end

				D = data{j}(id, k);

				plot(1:length(id), D);
				title([name, name2, ' ', period, ' Price']);
				ylabel('Price'); xlabel('Time');
				saveas(gcf, ['1', name, name2, ' ', period, ' Price.png']); 

				l = 5;
				R = (D(2:end) - D(1:end-1))./D(1:end-1);
				R = (R - mean(R))./std(R);
				histogram(R, 'Normalization', 'probability', 'BinWidth', 10/bins); hold on;
				plot(-l:0.1:l, norm01(-l:0.1:l)*2*l/bins); hold off;
				title([name, name2, ' ', period, ' Normalized Simple Return Distribution']);
				ylabel('Probability'); xlabel('Normalized Simple Return');
				saveas(gcf, ['2', name, name2, ' ', period, ' Normalized Simple Return Distribution.png']); 

				R = log(D);
				R = R(2:end) - R(1:end-1);
				R = (R - mean(R))./std(R);
				histogram(R, 'Normalization', 'probability', 'BinWidth', 10/bins); hold on;
				plot(-l:0.1:l, norm01(-l:0.1:l)*2*l/bins); hold off;
				title([name, name2, ' ', period, ' Normalized Log Return Distribution']);
				ylabel('Probability'); xlabel('Normalized Log Return');
				saveas(gcf, ['3', name, name2, ' ', period, ' Normalized Log Return Distribution.png']); 

				D_old = D;
				R = log(D);
				R = R(2:end) - R(1:end-1);
				mu = mean(R);
				sig = std(R);
				l = int64(length(id)*4/5) + 1;
				c = 10;
				for p = l+1:length(id)
					D(p) = D(p-1)*exp(mu + sig*randn(1));
				end
				plot(l:length(id), D(l:end), l:length(id), D_old(l:end));
				title([name, name2, ' ', period, ' Generated Price']);
				ylabel('Price'); xlabel('Time');
				saveas(gcf, ['4', name, name2, ' ', period, ' Generated Price.png']); 

			end
		end
	end
end

function [y] = norm01(x)
	y = (1/(2*pi)^0.5)*exp(-(x.^2)/2);
end