function alpha_raw = alpha_statistical_ind(close,volume,IndGrp,NumDates,NumStocks)

% obtaining the data sets I need. Change them here directly if I want to
% create training and validation
closing = close;
% volume = volume;
ret1 = [zeros(NumStocks,1) close(1:end,2:end)./close(1:end,1:end-1)-1];
snpret1 = [0 snpclose(2:end)./snpclose(1:end-1)-1];

% Specifying the parameters
training_date = NumDates;
horizon = 10;
liq = 0.25;
lookback = 200;
pca_var_explained = 0.9;
spread_lim_short = 2;
spread_lim_long = 2;

% clean the data a bit and create the matrices to be used for the training
% random_idx = randsample(data.numstocks,1500);
avg_trading = nanmean(volume(:,1:training_date).*closing(:,1:training_date),2);
% avg_trading(random_idx) = 0;
low_trading = avg_trading<quantile(avg_trading,liq);
stocks_rem = low_trading;
clear avg_trading low_trading;

% creating the matrices we'll use
ret_horizon = [zeros(size(closing,1),horizon) closing(:,horizon+1:training_date)./closing(:,1:training_date-horizon)-1 ];
ret_horizon = ret_horizon(~stocks_rem,:);
ret1 = ret1(~stocks_rem,1:training_date);
prices = closing(~stocks_rem,1:training_date);
industry = IndGrp(~stocks_rem)';     


%%

alpha_raw = zeros(sum(~stocks_rem),training_date);
matrix = prices;    % The matrix based on which trading will be done

for i = lookback+horizon:horizon:training_date - horizon
    prev_vol = nanstd(ret_horizon(:,i-lookback+1:i),0,2);
    prev_vol(isnan(prev_vol)) = 1;

    uniq_ind = unique(industry);
    pos = zeros(sum(~stocks_rem),horizon);
    
    for j=1:length(uniq_ind)
        % not looking at liquidity since my horizon is large
        stocks_ind = industry==uniq_ind(j) & sum( isnan(matrix(:,i-lookback:i-1)) ,2)==0;
        if(sum(stocks_ind)>=20)
            stocks_ind_std = prev_vol(stocks_ind);
            stocks_ind_std = sort(stocks_ind_std);
            std_bound = stocks_ind_std(20);
            investable_stocks = stocks_ind & (prev_vol <= std_bound);
            % Creating the matrix based on which PCA will be done and
            % future trades decided
            mat_ind = matrix(investable_stocks,i-lookback:i-1);
            mat_pred = pca_reg_pred(mat_ind,pca_var_explained,horizon);
            % The spread by which the prediction has to exceed the actual
            spread = std(matrix(investable_stocks,i-horizon:i-1),0,2);
            
            invest_long_ind = ((matrix(investable_stocks,i:i+horizon-1) - mat_pred) <= -(spread_lim_long*repmat(spread,1,horizon)));
            invest_short_ind = ((matrix(investable_stocks,i:i+horizon-1) - mat_pred) >= (spread_lim_short*repmat(spread,1,horizon)));
            pos(investable_stocks,:) = -invest_long_ind.*(matrix(investable_stocks,i:i+horizon-1) - mat_pred) ...
                                        - invest_short_ind.*(matrix(investable_stocks,i:i+horizon-1) - mat_pred);
        end
    end
    
    alpha_raw(:,i:i+horizon-1) = pos;   
end

alpha_raw = alpha_raw(:,1:training_date);   % coz it can overshoot training_date

%% Balance
% alpha_raw = alpharaw10hor2007;
bal_trade = zeros(size(alpha_raw,1),size(alpha_raw,2));
for i = lookback:training_date
    % Iterating through each industry and making it neutral
    for j = 1:length(uniq_ind)
        % these are the indices of the stocks in the industry that can be
        % traded 
        stocks_ind = industry==uniq_ind(j);     
        stocks_invested = stocks_ind & alpha_raw(:,i)~=0;
        ind_other_stocks = ~stocks_invested & stocks_ind;
        
        % balancing with the other stocks
        total_traded = sum(alpha_raw(stocks_invested,i));
        num_other_stocks = sum(ind_other_stocks);
        if(sum(stocks_ind) >0)
            bal_trade(stocks_ind,i) = alpha_raw(stocks_ind,i) -total_traded/sum(stocks_ind);
        end
        
    end
end

alpha = zeros(NumStocks,NumDates);
alpha(~stocks_rem,1:training_date) = alpha_raw + bal_trade;


%% testing the strategy

% at this point we have alpha
% Lets obtain the daily pnl
check_alpha = alpha_raw;

pnl = check_alpha(:,1:end-1).*ret1(:,2:end);
pnl(isnan(pnl)) = 0;
daily_pnl = sum(pnl,1);
% Comparing with SnP
SnpPnl = snpret1(:,2:end);


sharpe = mean(daily_pnl)/std(daily_pnl)
sum(daily_pnl)/(mean(sum(abs(check_alpha),2)))*252/training_date



end


