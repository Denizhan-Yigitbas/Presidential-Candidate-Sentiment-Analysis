import tweepy
import preprocessor
import csv
from textblob import TextBlob

class TwitterUser():
    def __init__(self, twitterHandle, consumer_key, consumer_secret, access_key, access_secret):
        self.twitterHandle = twitterHandle
        self.consumer_key = consumer_key
        self.consumer_secret = consumer_secret
        self.access_key = access_key
        self.access_secret = access_secret
        self.allTweets = self.get_all_twitter_activity()

    def get_twitter_handle(self):
        """
        Returns the Twitter Handle of the current TwitterUser object
        """
    
        return self.twitterHandle
    
    def get_all_twitter_activity(self):
        """
        Returns all data about the most recent 3240 tweets and retweets for the TwitterUser
        """
        
        print("Retrieving data for @%s...." % self.get_twitter_handle())
        
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
        
        print("Data Retrieval Successful! \n")
        return allTweets
    
    def is_tweet(self, tweet):
        """
        Given a tweet, this will return true if this is a tweet and false if it is a retweet
        """
        if not hasattr(tweet, 'retweeted_status'):
            return True
        else:
            return False
        
    def get_all_tweet_data(self):
        """
        Returns a list of all data for only personal tweets by TwitterUser
        """
        tweets = []
        for tweet in self.allTweets:
            # checks to make sure 'tweet' is not a retweet
            if not hasattr(tweet, 'retweeted_status'):
                tweets.append(tweet)
        return tweets
    
    def get_all_retweet_data(self):
        """
        Returns a list of all data for only retweets by TwitterUser
        """
        retweets = []
        for retweet in self.allTweets:
            # checks to make sure 'tweet' is not a retweet
            if hasattr(retweet, 'retweeted_status'):
                retweets.append(retweet)
        return retweets
    
    def get_oldest_activity_date(self):
        """
        Returns date of the oldest tweet OR retweet by the TwitterUser 
        """
        lastIndex = len(self.allTweets) - 1
        return self.allTweets[lastIndex].created_at.date()
    
    def get_newest_activity_date(self):
        """
        Returns date of the newest tweet OR retweet by the TwitterUser
        """
        return self.allTweets[0].created_at.date()
    
    def get_oldest_tweet_date(self):
        """
        Returns date of the oldest personal tweet by the TwitterUser
        """
        tweetData= self.get_all_tweet_data()
        lastIndex = len(tweetData) - 1
        return tweetData[lastIndex].created_at.date()
        
    def get_newest_tweet_date(self):
        """
        Returns date of the newest personal tweet by the TwitterUser 
        """
        tweetData = self.get_all_tweet_data()
        return tweetData[0].created_at.date()
    
    def get_oldest_retweet_date(self):
        """
        Returns date of the oldest retweet by the TwitterUser
        """
        retweetData = self.get_all_retweet_data()
        lastIndex = len(retweetData) - 1
        return retweetData[lastIndex].created_at.date()
        
    def get_newest_retweet_date(self):
        """
        Returns date of the newest retweet by the TwitterUser
        """
        retweetData = self.get_all_retweet_data()
        return retweetData[0].created_at.date()
        
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
        #allTweets = self.get_all_twitter_activity()
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
        tweetData = self.get_all_tweet_data()
        for tweet in tweetData:
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
        retweetText = []
        retweetData = self.get_all_retweet_data()
        for retweet in retweetData:
            retweetText.append(retweet.retweeted_status.full_text)
        return retweetText

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
    
    def sentimentAnalysis(self, text):
        """
        Returns the polarity of a given text using TextBlob sentiment analysis
        """
        analyzed = TextBlob(text)
        polarity = analyzed.sentiment.polarity
        return polarity
    
    def prepare_cleaned_csv_tweet_data(self):
        """
        Returns 7 lists of data for only tweets that will be used as columns 
        for the csv that will be created using export_to_csv_cleaned_tweets()
        """
        tweetId = []
        tweetText = []
        tweetDate = []
        tweetFavCount = []
        tweetRetCount = []
        tweetPolarity = []
        tweetData = self.get_all_tweet_data()
        for tweet in tweetData:
            cleanedText = preprocessor.clean(tweet.full_text)
            if cleanedText == '':
                continue
            tweetId.append(tweet.id_str)
            tweetText.append(cleanedText)
            tweetDate.append(tweet.created_at.date())
            tweetFavCount.append(tweet.favorite_count)
            tweetRetCount.append(tweet.retweet_count)
            tweetPolarity.append(self.sentimentAnalysis(cleanedText))
        candidate = [self.twitterHandle] * len(tweetId)
        return candidate, tweetId, tweetText, tweetDate, tweetFavCount, tweetRetCount, tweetPolarity
    
    def export_to_csv_cleaned_tweets(self):
        """
        Creates a csv file for only tweets with the following columns:
        
        twitterHandle | tweet id | tweet text | post date | fav count | retweet count | tweet polarity
        """
        candData, idData, textData, dateData, favCountData, retweetCountData, polarityData = self.prepare_cleaned_csv_tweet_data()
        dataSet = list(zip(candData, idData, textData, dateData, favCountData, retweetCountData, polarityData))
        with open('%s_cleanedTweetsOnly.csv' % self.twitterHandle, 'w') as f:
            writer = csv.writer(f)
            writer.writerow(["candidate", "id", "text", "createdDate", "favoriteCount", "retweetCount", "polarity"])
            writer.writerows(dataSet)
        
    def prepare_all_data_csv_cleaned(self):
        """
        Returns 8 lists of data for BOTH CLEANED tweets AND retweets that will be used as columns
        for the csv that will be created using export_all_data_csv_cleaned()
        """
        tweetId = []
        tweetText = []
        tweetDate = []
        tweetFavCount = []
        tweetRetCount = []
        tweetPolarity = []
        tweetOrRetweet = []
        tweetData = self.allTweets
        for tweet in tweetData:
            if self.is_tweet(tweet):
                tweetOrRetweet.append(1)
                cleanedText = preprocessor.clean(tweet.full_text)
            else:
                tweetOrRetweet.append(0)
                cleanedText = preprocessor.clean(tweet.retweeted_status.full_text)
            if cleanedText == '':
                continue
            tweetId.append(tweet.id_str)
            tweetText.append(cleanedText)
            tweetDate.append(tweet.created_at.date())
            tweetFavCount.append(tweet.favorite_count)
            tweetRetCount.append(tweet.retweet_count)
            tweetPolarity.append(self.sentimentAnalysis(cleanedText))
        candidate = [self.twitterHandle] * len(tweetId)
        return candidate, tweetId, tweetText, tweetDate, tweetFavCount, tweetRetCount, tweetPolarity, tweetOrRetweet

    def export_all_data_csv_cleaned(self):
        """
        Creates a csv file for BOTH CLEANED tweets AND retweets with the following columns:

        twitterHandle | tweet id | tweet text | post date | fav count | retweet count | tweet polarity | tweet or retweet
        """
        candData, idData, textData, dateData, favCountData, retweetCountData, polarityData, tweetOrRetData \
            = self.prepare_all_data_csv_cleaned()
        dataSet = list(zip(candData, idData, textData, dateData, favCountData, retweetCountData, polarityData, tweetOrRetData))
        with open('%s_allActivityCleaned.csv' % self.twitterHandle, 'w') as f:
            writer = csv.writer(f)
            writer.writerow(["candidate", "id", "text", "createdDate", "favoriteCount", "retweetCount", "polarity", "tweetBinary"])
            writer.writerows(dataSet)

    def prepare_all_data_csv_uncleaned(self):
        """
        Returns 8 lists of data for BOTH UNCLEANED tweets AND retweets that will be used as columns
        for the csv that will be created using export_all_data_csv_uncleaned()
        """
        tweetId = []
        tweetText = []
        tweetDate = []
        tweetFavCount = []
        tweetRetCount = []
        tweetPolarity = []
        tweetOrRetweet = []
        tweetData = self.allTweets
        for tweet in tweetData:
            if self.is_tweet(tweet):
                tweetOrRetweet.append(1)
                text = tweet.full_text
            else:
                tweetOrRetweet.append(0)
                text = tweet.retweeted_status.full_text
            tweetId.append(tweet.id_str)
            tweetText.append(text)
            tweetDate.append(tweet.created_at.date())
            tweetFavCount.append(tweet.favorite_count)
            tweetRetCount.append(tweet.retweet_count)
            tweetPolarity.append(self.sentimentAnalysis(text))
        candidate = [self.twitterHandle] * len(tweetId)
        return candidate, tweetId, tweetText, tweetDate, tweetFavCount, tweetRetCount, tweetPolarity, tweetOrRetweet
    
    def export_all_data_csv_uncleaned(self):
        """
        Creates a csv file for BOTH UNCLEANED tweets AND retweets with the following columns:

        twitterHandle | tweet id | tweet text | post date | fav count | retweet count | tweet polarity | tweet or retweet
        """
        candData, idData, textData, dateData, favCountData, retweetCountData, polarityData, tweetOrRetData \
            = self.prepare_all_data_csv_uncleaned()
        dataSet = list(zip(candData, idData, textData, dateData, favCountData, retweetCountData, polarityData, tweetOrRetData))
        with open('%s_allActivityUnCleaned.csv' % self.twitterHandle, 'w') as f:
            writer = csv.writer(f)
            writer.writerow(["candidate", "id", "text", "createdDate", "favoriteCount", "retweetCount", "polarity", "tweetBinary"])
            writer.writerows(dataSet)
        

def combinedCleanedCSV(TwitterUserArray):
    """
    Given a list of TwitterUser objects, this will create a single csv file that contains BOTH CLEANED tweets and retweets
    of all the given TwitterUsers
    """
    finalDataSet = []
    for user in TwitterUserArray:
        candData, idData, textData, dateData, favCountData, retweetCountData, polarityData, tweetOrRetData = user.prepare_all_data_csv_cleaned()
        userDataSet = list(zip(candData, idData, textData, dateData, favCountData, retweetCountData, polarityData, tweetOrRetData))
        finalDataSet.extend(userDataSet)
    with open('customTwitterUsersCombinedCleaned.csv', 'w') as f:
        writer = csv.writer(f)
        writer.writerow(
            ["candidate", "id", "text", "createdDate", "favoriteCount", "retweetCount", "polarity", "tweetBinary"])
        writer.writerows(finalDataSet)

def combinedUncleanedCSV(TwitterUserArray):
    """
    Given a list of TwitterUser objects, this will create a single csv file that contains BOTH UNCLEANED tweets and retweets
    of all the given TwitterUsers
    """
    finalDataSet = []
    for user in TwitterUserArray:
        candData, idData, textData, dateData, favCountData, retweetCountData, polarityData, tweetOrRetData = user.prepare_all_data_csv_uncleaned()
        userDataSet = list(zip(candData, idData, textData, dateData, favCountData, retweetCountData, polarityData, tweetOrRetData))
        finalDataSet.extend(userDataSet)
    with open('customTwitterUsersCombinedUncleaned.csv', 'w') as f:
        writer = csv.writer(f)
        writer.writerow(
            ["candidate", "id", "text", "createdDate", "favoriteCount", "retweetCount", "polarity", "tweetBinary"])
        writer.writerows(finalDataSet)
