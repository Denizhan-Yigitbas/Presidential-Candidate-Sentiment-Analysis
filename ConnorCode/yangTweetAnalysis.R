#install.packages("dplyr")
#install.packages("purrr")
#install.packages("twitteR")
#install.packages("tidyr")
#install.packages("lubridate")
#install.packages("scales")
#intall.packages("tidyverse")
#intall.packages("ggplot2")
#install.packages("tidytext")
library(dplyr)
library(purrr)
library(twitteR)
library(tidyr)
library(lubridate)
library(scales)
library(tidyverse)
library(ggplot2)
library(tidytext)

consumer_key <- "fsIJrsm2M2H7EqhBTAY2L2FE6"
consumer_secret <- "pEImfs7hw6OXPA3coF4ySPq5tkzAMOXfjfYVRpPUQlRUbDHVos"
access_token <- "723047418-ssrsLkCiMNg1zGrJCVTL6HhPeUSllMf8KrQ6W2TA"
access_secret <- "Zfr7jCXX5iM7N0VlRqtvmJ46RqBukmt2Q4QUKnxsn7g2h"

setup_twitter_oauth(consumer_key, consumer_secret, access_token, access_secret)
Yes
yangtweets <- userTimeline("AndrewYang", n = 3200)
yang <- tbl_df(map_df(yangtweets, as.data.frame))
yang$candidate <- "Yang"
#roadblock: tweet text gets truncated if > 140 characters; how to fix?

head(yang)

#we can clean data pretty significantly

yang <- yang %>%
  select(id, text, createdDate, favoriteCount, retweetCount, candidate)

yang

#tbh no idea what "id" is, but this leaves us with:
## text of tweet
## date and time of creation
## favs
## retweets

#tweet per time of day

yang %>%
  count(n(), hour = hour(with_tz(createdDate, "EST"))) %>%
  mutate(percent = n / sum(n)) %>% 
  ggplot(aes(hour, percent)) +
  geom_line() +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Hour of day (EST)",
       y = "% of tweets")

# comparison of words

reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"
yang_tweet_words <- yang %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = reg) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]"))

yang_tweet_words %>% count(word) %>% 
  arrange(desc(n)) %>% 
  filter(n>5) %>% 
  filter(word!="time", word!="coming",word!="ve") %>% 
  ggplot(aes(x=reorder(word,n), y=n)) +
  geom_bar(stat="identity") +
  coord_flip() +
  xlab("Word") +
  ylab("Occurences") +
  ggtitle("Andrew Yang's Most Frequently Used Words on Twitter", subtitle="Excluding common 'stop words'") 

###SENTIMENT ANALYSIS
nrc <- sentiments %>%
  filter(lexicon == "nrc") %>%
  dplyr::select(word, sentiment)

### the code below initially grouped yang' tweets by source
## Because we are grouping by candidate and not source, we will need to tweak 
# group_by(source) should be group_by(candidate)
# but this requires we have a dataset of all candidates tweets in one
# as a proof of concept, i've made the tweets grouped by time of creation (createdDate) 

yangsources <- yang_tweet_words %>%
  group_by(createdDate) %>%
  mutate(total_words = n()) %>%
  ungroup() %>%
  distinct(id, createdDate, total_words, candidate)

yang_by_source_sentiment <- yang_tweet_words %>%
  inner_join(nrc, by = "word") %>%
  count(sentiment, id) %>%
  ungroup() %>%
  complete(sentiment, id, fill = list(n = 0)) %>%
  inner_join(yangsources) %>%
  group_by(candidate,createdDate, sentiment, total_words) %>%
  summarize(words = sum(n)) %>%
  ungroup()

# what yang_by_source_sentiment tells us is the frequency of a given word's sentiment on a given time/day (tweet)
# "words" captures the number of words of a given sentiment in a tweet
# "total_words captures the total number of words in a tweet, excluding stop-words
# for example, the tweet posted on 9/21/2018 at 21:29 o'clock was six words, 
# and one word was coded trust, one word was positive, and one word was joy
# re above: how to keep retweets/likes?

# plot changes in sentiment over time
yangtest1 <- yang_by_source_sentiment %>% 
  group_by(sentiment) %>% 
  mutate(percent = words/total_words) 
ggplot(aes(x=date(createdDate), y=percent, fill = sentiment), data=yangtest1) +
  geom_col() 
# this is maybe the right idea but?

# find overall sentiment in tweets
yangtest2 <- yang_by_source_sentiment %>% 
  group_by(sentiment) %>% 
  mutate(percent = words/total_words) %>% 
  summarise(mean=mean(percent)) %>% 
  ggplot(aes(x=reorder(sentiment,mean),y=mean)) +
  geom_col() +
  coord_flip()

yangtest2
# output: sentiment is positive 17% of the time, anticipatory 11% of the time, evokes trust 11% of the time
# joy 7% of the time, etc.
