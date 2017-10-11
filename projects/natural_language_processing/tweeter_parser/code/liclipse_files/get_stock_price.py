#This code was borrowed from the below post  
#http://stackoverflow.com/questions/24233385/pulling-yahoo-finance-data-using-python
#Modified by Frederic Marechal

import urllib.request
import time
import datetime

#This function takes a stock name (e.g. GOOGL), connect to the YAHOO!Finance API.
#It downloads the stock data for the date t, t-1 and t-2. 
#It transforms the streamed data in a CSV and store the file locally.
#The result is a file containing the following attributes Date/Open/High/Low/Close/Volume
def pullData(stock):
    current_date = datetime.datetime.now().strftime('%Y_%m_%d')
    fileLine = "data/prices/" + stock + '_' +current_date + '_.csv'
    #Create the YAHOO!finance request URL, based on the stock name 
    urltovisit = 'http://chartapi.finance.yahoo.com/instrument/1.0/'+stock+'/chartdata;type=quote;range=3d/csv'
    #Call the YAHOO!Finance API and get the data
    with urllib.request.urlopen(urltovisit) as f:
        sourceCode = f.read().decode('utf-8')
    splitSource = sourceCode.split('\n')
    #Transform the stream into a CSV format and store.
    for eachLine in splitSource:
        splitLine = eachLine.split(',') 
        if len(splitLine) == 6: 
            if 'values' not in eachLine:
                saveFile = open(fileLine,'a')
                linetoWrite = eachLine+'\n'
                saveFile.write(linetoWrite)

    print('Pulled', stock)
    print('...')
    time.sleep(.5)


#get the price for each stock in the list
#stockstoPull = 'GOOGL',
#for eachStock in stockstoPull:     
#    pullData(eachStock)

#To read the datetime
#import datetime
#open/close 
#print(datetime.datetime.fromtimestamp(1477575248).strftime('%Y-%m-%d %H:%M:%S'))
#print(datetime.datetime.fromtimestamp(1477684800).strftime('%Y-%m-%d %H:%M:%S'))
#open/close 
#print(datetime.datetime.fromtimestamp(1477920842).strftime('%Y-%m-%d %H:%M:%S'))
#print(datetime.datetime.fromtimestamp(1477944000).strftime('%Y-%m-%d %H:%M:%S'))


