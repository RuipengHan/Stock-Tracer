import yfinance as yahooFinance
# import yfinance.shared as shared
# Guide on this API: https://algotrading101.com/learn/yfinance-guide/
import csv
tickers = []
def GetSymbols():
    # Data retrieved at https://stockmarketmba.com/stocksinthesp500.php
    with open('data/sp500.csv', mode ='r')as file:
        # reading the CSV file
        csvFile = csv.reader(file)
        # displaying the contents of the CSV file
        i = 0
        for lines in csvFile:
            if i == 0:
                i+=1
                continue
            tickers.append(lines[0])
                
GetSymbols()

def DownloadHistoricalData(tickers):
    i = 0
    for ticker in tickers:
        i+=1
        print(f'{i}: Currently downloading data for ticker: {ticker}')

        data = yahooFinance.download(ticker, period="max", interval="1d")
        data.to_csv(f'data/{ticker}.csv')
    print("Done!")

def DownloadHistoricalDataByBulk(tickers):
    data = yahooFinance.download(tickers, period="max", interval="1d", group_by="tickers")
    data.iloc[:, data.columns.get_level_values(1)=='Close']
    data.to_csv('test/sp500_historical.csv')

DownloadHistoricalData(tickers)
# DownloadHistoricalDataByBulk("META AAPL")

# data = yahooFinance.download("AMZN AAPL GOOG", period="max", group_by='tickers')
# data.to_csv('data/file_name.csv')
# print(type(data))    
# print(data)


# BRK-B BF-B
# data = yahooFinance.download("BRK-B", period="max", interval="1d")
# data.to_csv('data/BRK-B.csv')
