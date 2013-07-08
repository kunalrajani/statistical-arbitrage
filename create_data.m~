
% Obtain the stock price information for the stocks
StartDt = '01012007';
EndDt = '30082012';
stocks_data2 = hist_stock_data(StartDt,EndDt,'tics.txt');
save('all_stocks_data.mat','stocks_data2');

% Create a dataset of the closing stock prices
TotalStocks = length(stocks_data2);
dummy = zeros(1,TotalStocks);
for i = 1:TotalStocks;
    dummy(i) = length(stocks_data2(i).Date);
end
[a b] = grpstats(dummy',dummy',{'numel' 'mean'});
% The above shows that NumDates = 881

NumDates = b(a==max(a));
NumStocks = max(a);
close = zeros(NumStocks,NumDates);
volume = zeros(NumStocks,NumDates);
tics = [];

j = 0;
for i = 1:TotalStocks
    if(length(stocks_data2(i).Date)==NumDates)
        j = j+1;
        tics = strvcat(tics,stocks_data2(i).Ticker);
        close(j,:) = stocks_data2(i).AdjClose(end:-1:1)';
        volume(j,:) = stocks_data2(i).Volume(end:-1:1)';
    end
end
tics = cellstr(tics);

%% Creating the Industry mapping
all_tics =[];
fid = fopen('tics_ind_grp.txt','r');
grps = fscanf(fid,'%d');
fid = fopen('tics.txt');
temp_tic = fgets(fid);
while(length(temp_tic)>=1 & temp_tic ~= -1)
        all_tics = strvcat(all_tics,temp_tic);
        temp_tic = fgets(fid);
end
all_tics = cellstr(all_tics);
IndGrpMap = containers.Map(all_tics,grps);

for i = 1:NumStocks
    IndGrp(i) = IndGrpMap(char(tics(i)));   %The IndGrpMap is already defined
end

%% Obtaining SNP data
snp = hist_stock_data_brief('01/01/2007','08/30/2012',{'^GSPC'});
snpclose = snp.AdjClose(end:-1:1)';

%% now calling the alpha
alpharaw10hor2007 = alpha_statistical_ind(close,volume,IndGrp,NumDates,NumStocks);
