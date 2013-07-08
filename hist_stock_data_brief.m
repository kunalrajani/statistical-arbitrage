function stocks = hist_stock_data(start_date, end_date, tickers,varargin)
stocks = struct([]);        % initialize data structure

% split up beginning date into day, month, and year.  The month is
% subracted is subtracted by 1 since that is the format that Yahoo! uses
bd = start_date(4:5);       % beginning day
bm = sprintf('%02d',str2double(start_date(1:2))-1); % beginning month
by = start_date(7:10);       % beginning year

% split up ending date into day, month, and year.  The month is subracted
% by 1 since that is the format that Yahoo! uses
ed = end_date(4:5);         % ending day
em = sprintf('%02d',str2double(end_date(1:2))-1);   % ending month
ey = end_date(7:10);         % ending year

% determine if user specified frequency
temp = find(strcmp(varargin,'frequency') == 1); % search for frequency
if isempty(temp)                            % if not given
    freq = 'd';                             % default is daily
else                                        % if user supplies frequency
    freq = varargin{temp+1};                % assign to user input
    varargin(temp:temp+1) = [];             % remove from varargin
end
clear temp

h = waitbar(0, 'Please Wait...');           % create waitbar
idx = 1;                                    % idx for current stock data

% cycle through each ticker symbol and retrieve historical data
for i = 1:length(tickers)
    
    % update waitbar to display current ticker
    waitbar((i-1)/length(tickers),h,sprintf('%s %s %s%0.2f%s', ...
        'Retrieving stock data for',tickers{i},'(',(i-1)*100/length(tickers),'%)'))
        
% download historical data using the Yahoo! Finance website
    [temp, status] = urlread(strcat('http://ichart.finance.yahoo.com/table.csv?s='...
        ,tickers{i},'&a=',bm,'&b=',bd,'&c=',by,'&d=',em,'&e=',ed,'&f=',...
        ey,'&g=',freq,'&ignore=.csv'));
    
    if status
        % organize data by using the comma delimiter
        [date, op, high, low, cl, volume, adj_close] = ...
            strread(temp(43:end),'%s%s%s%s%s%s%s','delimiter',',');

        stocks(idx).Ticker = tickers{i};        % obtain ticker symbol
        stocks(idx).Date = date;                % save date data
        stocks(idx).Open = str2double(op);      % save opening price data
        stocks(idx).High = str2double(high);    % save high price data
        stocks(idx).Low = str2double(low);      % save low price data
        stocks(idx).Close = str2double(cl);     % save closing price data
        stocks(idx).Volume = str2double(volume);      % save volume data
        stocks(idx).AdjClose = str2double(adj_close); % save adjustied close data
        
        idx = idx + 1;                          % increment stock index
    end
       
    % clear variables made in for loop for next iteration
    clear date op high low cl volume adj_close temp status
    
    % update waitbar
    waitbar(i/length(tickers),h)
end

close(h)    % close waitbar