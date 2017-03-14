id = 'nonindex';
m = 10;
n = 1240;

names = {'atlas.csv', 'camlin.csv', 'dlf.csv', 'glaxo.csv', 'indiabulls.csv', 'tata_coffee.csv', 'colgate.csv', 'pnb.csv', 'suzlon.csv', 'tatachemicals.csv'}

data = zeros(n, m);

for i = 1:length(names)
	names{i}
	data(:, i) = csvread([id, '/', names{i}], 1, 4, [1 4 n 4]);
end

csvwrite([id, 'data1'], data);