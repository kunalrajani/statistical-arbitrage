
Abstract

The objective of this analysis is to obtain an alpha that is based on statistically exploring inefficiencies in stock prices. The strategy involves decomposing stock prices in each industry into principal components that explain the most variance and then regress the stock prices on those components to obtain the stock's  dependence on them. Next the components are forecasted using GARCH model and hence the forecasted evolution of the stocks is also obtained based on the regression results. Based on these forecasts I will create a long-short neutral arbitrage strategy with the aim of achieving high risk adjusted returns.


create_data.m is used to pull data for a list of tickers from yahoo finance and parse the information as relevant objects in matlab.
It uses hist_stock_data.m and hist_stock_data_brief.m to connect to yahoo and extract that information.

alpha_statistical_ind.m is the main code that creates the strategy using the data. The parameters of the strategy are listed at the top
and the algorithm then follows.

pca_reg_pred.m is the heart of the strategy. At every rebalancing instant it takes the stock prices, conducts a PCA decomposition on them
to identify the top components that explain the variance. Then it regresses the stock prices on those components and models those components
using ARMA/GARCH. After extrapolating those components it obtains the stock prices in the immediate future.

Once these prices are obtained the investment decisions is made based on the difference between these predictions and the actual price of the stock.





Disclaimer: Please read:
Please note that this is my independent work where I have used data from yahoo finance to explore statistical concepts from a course I took in statistics. It may, inadvertently, have an overlap with a work that somebody else has already done and I have no intentions of replicating it. I would be glad to know of any such clash and post an addendum in this README.
Redistribution of this work is permitted only after due credit and a reference has been provided. Feel free to contact me to avoid any misunderstandings or if you need more details from this paper. 


