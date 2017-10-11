import time
import datetime
import get_twitter_data
import get_stock_price

#This is a simple scheduler that fetch market data and 
#Twitter's sentiments every hour 
while True:
    #Get the current date
    current_date = datetime.datetime.now()
    current_date_str = current_date.strftime('%Y-%m-%d-%H.%M.%S')
    
    #The stock market ticker 
    keyword = 'GOOGL'

    #Fetch the Twitter data for today
    the_time = 'today'
    twitterData = get_twitter_data.TwitterData()
    tweets = twitterData.getTwitterData(keyword, the_time)

    #Fetch the market data 
    if (current_date > datetime.datetime(current_date.year, current_date.month, current_date.day, 21, 30, 0,0) and
        current_date < datetime.datetime(current_date.year, current_date.month, current_date.day, 23, 0, 0,0)):
        get_stock_price.pullData(keyword)
    
    print("ran at: " + current_date_str)
    time.sleep(3600)