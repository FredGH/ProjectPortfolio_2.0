#from ravik... .net

import argparse
import urllib
import json
import datetime
import random
import os
import pickle
from datetime import timedelta
import oauth2
import urllib.parse

import csv
import get_twitter_data
import json
import uuid

class TwitterData:
    #Class constructor - set the parameters that will be used by the object at runtime 
    def __init__(self):
        self.currDate = datetime.datetime.now()
        self.weekDates = []
        self.weekDates.append(self.currDate.strftime("%Y-%m-%d"))
        for i in range(-1,7):
            dateDiff = timedelta(days=-i)
            newDate = self.currDate + dateDiff
            self.weekDates.append(newDate.strftime("%Y-%m-%d"))
            
    #Get the Twitter data stream based on a keyword (e.g. GOODL), and a timeframe (e.g. today, yesterday, etc..)  
    def getTwitterData(self, keyword, time):
        self.weekTweets = {}
        #Set the current date to a string    
        current_date = datetime.datetime.now().strftime('%Y-%m-%d-%H.%M.%S')
        #Get the Twitter information for a timeframe
        if(time == 'lastweek'):
            for i in range(0,6):
                params = {'since': self.weekDates[i+1], 'until': self.weekDates[i]}
                self.weekTweets[i] = self.getData(keyword, params)
            
            filename = 'data/weekTweets/weekTweets_'+urllib.parse.unquote(keyword.replace("+", " "))+ "_" + current_date + "_" + time +'.txt'
            outfile = open(filename, 'wb')        
            pickle.dump(self.weekTweets, outfile)        
            outfile.close()
        elif(time == 'yesterdayAndToday'):
            for i in range(0,2):
                params = {'since': self.weekDates[i], 'until': self.weekDates[i+1]}
                self.weekTweets[i] = self.getData(keyword, params)
        elif(time == 'today'):
            for i in range(0,1):
                params = {'since': self.weekDates[i], 'until': self.weekDates[i+1]} 
                self.weekTweets[i] = self.getData(keyword, params) 
        #Define a file name 
        fileName = 'data/weekTweets/tweet' + '_' + keyword + '_' + time + '_' + 'tweets' +  "_" + current_date + "_" + time + '.csv'
        #Create a csv writer object and store both the schema and data into it
        csv_out = open(fileName, mode='w', newline='') 
        writer = csv.writer(csv_out) 
        fields = ['created_at', 'text'] 
        writer.writerow(fields) 
        #print the values to the CSV
        print ("start writing Tweets to csv: " + keyword +  "_" + current_date + "_" + time )
        for item in self.weekTweets.values():
            #writes a row and gets the fields from the json object
            #screen_name and followers/friends are found on the second level hence two get methods)
            i = 0
            while (i < len(item)-1):
                writer.writerow([self.encode_string(item[i]),self.encode_string(item[i+1])])
                i = i+1
        csv_out.close()
        print ("End writing Tweets to csv: " + keyword +  "_" + current_date + "_" + time )
            
        return self.weekTweets

    #Encode a string to unicode
    def encode_string(self, str):
        return str.encode('unicode-escape',errors='strict')
    
    #The configuration parser. It loads the 'config.json' file and 
    #gather the Twitter authorisation tokens to establish a connection with the Twitter's aPI 
    def parse_config(self):
      config = {}
      # Load the config information from a file
      if os.path.exists('config.json'):
          with open('config.json') as f:
              config.update(json.load(f))
      else:
          # Else load them from a command line
          parser = argparse.ArgumentParser()

          parser.add_argument('-ck', '--consumer_key', default=None, help='Your developper `Consumer Key`')
          parser.add_argument('-cs', '--consumer_secret', default=None, help='Your developper `Consumer Secret`')
          parser.add_argument('-at', '--access_token', default=None, help='A client `Access Token`')
          parser.add_argument('-ats', '--access_token_secret', default=None, help='A client `Access Token Secret`')

          args_ = parser.parse_args()
          def val(key):
            return config.get(key)\
                   or getattr(args_, key)\
                   or input('Your developper `%s`: ' % key)
          config.update({
            'consumer_key': val('consumer_key'),
            'consumer_secret': val('consumer_secret'),
            'access_token': val('access_token'),
            'access_token_secret': val('access_token_secret'),
          })
      return config

    #This function takes a Twitter's URL and establish a connection based on the configuration authorisation/authentication details 
    def oauth_req(self, url, http_method="GET", post_body=None,
                  http_headers=None):
      config = self.parse_config()
      
      consumer = oauth2.Consumer(key=config.get('consumer_key'), secret=config.get('consumer_secret'))
      
      token = oauth2.Token(key=config.get('access_token'), secret=config.get('access_token_secret'))
      client = oauth2.Client(consumer, token)
   
      resp, content = client.request(
          url,
          method=http_method,
          body=post_body or b"",
          headers=http_headers
      )
      return content
    
    #start getTwitterData
    def getData(self, keyword, params = {}):
        maxTweets = 100
        url = 'https://api.twitter.com/1.1/search/tweets.json?'    
        data = {'q': keyword, 
                'lang': 'en', 
                'result_type': 'recent', 
                'count': maxTweets, 
                'include_entities': 0, 
                'result_type':'mixed'}

        #Add if additional params are passed
        if params:
            for key, value in params.items():
                data[key] = value
        
        url += urllib.parse.urlencode(data)
        
        response = self.oauth_req(url)
        jsonData = json.loads(str(response,'utf-8'))
        tweets = []
        #https://dev.twitter.com/rest/reference/get/search/tweets
        if 'errors' in jsonData:
            print ("API Error")
            print (jsonData['errors'])
        else:
            for item in jsonData['statuses']:
                tweets.append(self.defaultValue(item,'created_at'))
                tweets.append(self.defaultValue(item,'text'))
        return tweets      
    
    def defaultValue(self, item, name, defaultValue=""):   
        if not isinstance(item[name], (bool)):
            if len(item[name]) > 0:
                return item[name] 
            else:
                return defaultValue 
        return item[name];    
    