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

harristweets <- userTimeline("KamalaHarris", n = 3200)
harris <- tbl_df(map_df(harristweets, as.data.frame))
#roadblock: tweet text gets truncated if > 140 characters; how to fix?

head(harris)

#we can clean data pretty significantly

harris <- harris %>%
  select(id, text, created, favoriteCount, retweetCount)

harris

#tbh no idea what "id" is, but this leaves us with:
## text of tweet
## date and time of creation
## favs
## retweets

#tweet per time of day

harris %>%
  count(n(), hour = hour(with_tz(created, "EST"))) %>%
  mutate(percent = n / sum(n)) %>% 
  ggplot(aes(hour, percent)) +
  geom_line() +
  scale_y_continuous(labels = percent_format()) +
  labs(x = "Hour of day (EST)",
       y = "% of tweets")

# comparison of words

reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"
harris_tweet_words <- harris %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>%
  unnest_tokens(word, text, token = "regex", pattern = reg) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]"))

harris_tweet_words %>% count(word) %>% 
  arrange(desc(n)) %>% 
  filter(n>40) %>% 
  filter(word!="day", word!="time") %>% 
  ggplot(aes(x=reorder(word,n), y=n)) +
  geom_bar(stat="identity") +
  coord_flip() +
  xlab("Word") +
  ylab("Occurences") +
  ggtitle("Kamala Harris' Most Frequently Used Words on Twitter", subtitle="Excluding common 'stop words'") 

###SENTIMENT ANALYSIS
nrc <- sentiments %>%
  filter(lexicon == "nrc") %>%
  dplyr::select(word, sentiment)

### the code below initially grouped harris' tweets by source
## Because we are grouping by candidate and not source, we will need to tweak 
# group_by(source) should be group_by(candidate)
# but this requires we have a dataset of all candidates tweets in one
# as a proof of concept, i've made the tweets grouped by time of creation (created) 

# the following is wrong
harrissources <- harris_tweet_words %>%
  group_by(created) %>%
  mutate(total_words = n()) %>%
  ungroup() %>%
  distinct(id, created, total_words)

harris_by_source_sentiment <- harris_tweet_words %>%
  inner_join(nrc, by = "word") %>%
  count(sentiment, id) %>%
  ungroup() %>%
  complete(sentiment, id, fill = list(n = 0)) %>%
  inner_join(harrissources) %>%
  group_by(created, sentiment, total_words) %>%
  summarize(words = sum(n)) %>%
  ungroup()

test1 <- harris_by_source_sentiment %>% 
  group_by(sentiment) %>% 
  mutate(percent = total_words/sum(total_words)) 
  ggplot(aes(x=created, y=percent, color = sentiment), data=test1) +
  geom_line() 
  
  tweets %>%
    count(source, hour = hour(with_tz(created, "EST"))) %>%
    mutate(percent = n / sum(n)) %>%
    ggplot(aes(hour, percent, color = source)) +
    geom_line() +
    scale_y_continuous(labels = percent_format()) +
    labs(x = "Hour of day (EST)",
         y = "% of tweets",
         color = "")
