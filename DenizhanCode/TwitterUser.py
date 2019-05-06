import tweepy
import preprocessor


class TwitterUser():
    def __init__(self, twitterHandle, consumer_key, consumer_secret, access_key, access_secret):
        self.twitterHandle = twitterHandle
        self.consumer_key = consumer_key
        self.consumer_secret = consumer_secret
        self.access_key = access_key
        self.access_secret = access_secret
        self.allTweets = self.get_all_tweets()

    def get_twitter_handle(self):
        """
        Returns the Twitter Handle of the current TwitterUser object
        """
    
        return self.twitterHandle
    
    def get_all_tweets(self):
        """
        Returns all data about the most recent 3240 tweets for the TwitterUser
        """
        
        print("Retrieving data for @%s.... \n" % self.get_twitter_handle())
        
        # Twitter only allows access to a users most recent 3240 tweets with this method
        # authorize twitter, initialize tweepy
        auth = tweepy.OAuthHandler(self.consumer_key, self.consumer_secret)
        auth.set_access_token(self.access_key, self.access_secret)
        api = tweepy.API(auth)
    
        # initialize a list to hold all the tweepy Tweets
        allTweets = []
    
        # make initial request for most recent tweets (200 is the maximum allowed count)
        newTweets = api.user_timeline(screen_name=self.twitterHandle, tweet_mode="extended", count=200)
    
        # save most recent tweets
        allTweets.extend(newTweets)
    
        # save the id of the oldest tweet less one
        oldest = allTweets[-1].id - 1
    
        # keep grabbing tweets until there are no tweets left to grab
        while len(newTweets) > 0:
            # print("getting tweets before %s" % (oldest))
        
            # all subsiquent requests use the max_id param to prevent duplicates
            newTweets = api.user_timeline(screen_name=self.twitterHandle, tweet_mode="extended", count=200, max_id=oldest)
        
            # save most recent tweets
            allTweets.extend(newTweets)
        
            # update the id of the oldest tweet less one
            oldest = allTweets[-1].id - 1
        
            # print("...%s tweets downloaded so far" % (len(allTweets)))
    
        return allTweets
        
    def num_tot_tweets_retrieved(self):
        """
        Returns the total number of tweets and retweets that were retrieved for the TwitterUser
        """
        
        return len(self.allTweets)
    
    def num_tweets_retrieved(self):
        """
        Returns the total number of personal tweets that are retrieved
        """
        
        tweetCount = 0
        for tweet in self.allTweets:
            # checks to make sure 'tweet' is not a retweet
            if not hasattr(tweet, 'retweeted_status'):
                tweetCount += 1
        return tweetCount
                
    def num_retweets_retrieved(self):
        """
        Returns the total number of retweets that are retrieved
        """
        #allTweets = self.get_all_tweets()
        retweetCount = 0
        for tweet in self.allTweets:
            # checks to make sure 'tweet' is not a retweet
            if hasattr(tweet, 'retweeted_status'):
                retweetCount += 1
        return retweetCount
        
    def all_tweet_text(self):
        """
        Returns a list of the text contents of the TwitterUser's tweets and retweets.
        This includes everything in text content(emoji, url, etc.)
        """

        tweetText = []
        for tweet in self.allTweets:
            # checks to make sure 'tweet' is not a retweet
            if not hasattr(tweet, 'retweeted_status'):
                tweetText.append(tweet.full_text)
            # for retweets
            else:
                tweetText.append(tweet.retweeted_status.full_text)
        return tweetText
    
    def tweet_only_text(self):
        """
        Returns a list of the text contents of the TwitterUser's TWEETS.
        This includes everything in text content(emoji, url, etc.)
        """
        tweetText = []
        for tweet in self.allTweets:
            # checks to make sure 'tweet' is not a retweet
            if not hasattr(tweet, 'retweeted_status'):
                tweetText.append(tweet.full_text)
        return tweetText
    
    def tweet_only_text_cleaned(self):
        """
        Returns a list of CLEANED text contents of the TwitterUser's TWEETS using the
        tweet-preprocessor library.
        
        Also removes tweets with no text content after cleaning
        """
        tweetOnlyTexts = self.tweet_only_text()
        cleanedTweets = []
        for tweet in tweetOnlyTexts:
            cleaned = preprocessor.clean(tweet)
            # if tweet has no content (for example, just a url)
            if cleaned == '':
                continue
            cleanedTweets.append(cleaned)
        return cleanedTweets
    
    def retweet_only_text(self):
        """
        Returns a list of the text contents of the TwitterUser's RETWEETS.
        This includes everything in text content(emoji, url, etc.)
        """
        tweetText = []
        for retweet in self.allTweets:
            # checks to make sure 'tweet' is a retweet
            if hasattr(retweet, 'retweeted_status'):
                tweetText.append(retweet.retweeted_status.full_text)
        return tweetText

    def retweet_only_text_cleaned(self):
        """
        Returns a list of CLEANED text contents of the TwitterUser's RETWEETS using the
        tweet-preprocessor library.
        
        Also removes tweets with no text content after cleaning
        """
        retweetOnlyTexts = self.retweet_only_text()
        cleanedRetweets = []
        for retweet in retweetOnlyTexts:
            cleaned = preprocessor.clean(retweet)
            # if tweet has no content (for example, just a url)
            if cleaned == '':
                continue
            cleanedRetweets.append(cleaned)
        return cleanedRetweets
    

    # # transform the tweepy tweets into a 2D array that will populate the csv
    # outtweets = [[tweet.id_str, tweet.created_at, tweet.text.encode("utf-8")] for tweet in allTweets]
    #
    # return outtweets
    # dates = [[tweet.created_at] for tweet in allTweets]
    # datesData = {}
    # for d in dates:
    #     month = d[0].month
    #     year = d[0].year
    #     if year == 2019:
    #         if month not in datesData:
    #             datesData[month] = 1
    #         else:
    #             datesData[month] += 1
    #
    # import matplotlib.pylab as plt
    #
    # lists = sorted(datesData.items())  # sorted by key, return a list of tuples
    #
    # x, y = zip(*lists)  # unpack a list of pairs into two tuples
    #
    # x = ("Jan", "Feb", "Mar", "Apr", "May")
    #
    # plt.bar(x, y)
    # plt.xlabel("Month")
    # plt.xticks(rotation=70)
    # plt.ylabel("Number of Tweets")
    # plt.title("Bernie Sander Twitter Usage for 2019")
    # plt.grid()
    # plt.show()
    #
    # # print(len(outtweets))
    # # # write the csv
    # # with open('%s_tweets.csv' % screen_name, 'w') as f:
    # #     writer = csv.writer(f)
    # #     writer.writerow(["id", "created_at", "text"])
    # #     writer.writerows(outtweets)
    # #
    # pass

consumer_key = 'fsIJrsm2M2H7EqhBTAY2L2FE6'
consumer_secret = 'pEImfs7hw6OXPA3coF4ySPq5tkzAMOXfjfYVRpPUQlRUbDHVos'
access_key = '723047418-ssrsLkCiMNg1zGrJCVTL6HhPeUSllMf8KrQ6W2TA'
access_secret = 'Zfr7jCXX5iM7N0VlRqtvmJ46RqBukmt2Q4QUKnxsn7g2h'

Connor = TwitterUser('CL_Rothschild', consumer_key, consumer_secret, access_key, access_secret)

print(Connor.get_twitter_handle())

text = Connor.tweet_only_text()
