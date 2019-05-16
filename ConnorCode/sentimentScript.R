### STEP TWO: RUN SENTIMENT ANALYSES 
### USE THIS ONCE DATA IS CLEANED AND
### DATA IS ALL IN ONE SHEET

library(dplyr)
library(purrr)
library(twitteR)
library(tidyr)
library(lubridate)
library(scales)
library(tidyverse)
library(ggplot2)
library(tidytext)
library(readr)
library(sentimentr)
library(dplyr)
library(syuzhet)
library(broom)
library(cleanNLP)
library(textclean)

# add sentiment per tweet, move sentiment and tweet text to front of dataset
# get_sentiment is from the syuzhet package, and by default uses the syuzhet dictionary
# mutate: variable for Tweets mentioning Trump and not 
archivedtweets <- cleanedtweets %>% 
  mutate(sentimentscale = get_sentiment(text)) %>% 
  mutate(mentiontrump = ifelse(str_detect(text, "Trump")==TRUE,yes=1,no=0)) %>% 
  select(-c(polarity)) %>% 
  select(sentimentscale, text, everything())

### NEW: Using sentimentr package's "sentiment" function instead of syuzhet.
## It differs from syuzhet in that it looks at 
## sentence level data instead of word-level
## this is preferable due to valence shifters 
# reference https://blog.exploratory.io/twitter-sentiment-analysis-scoring-by-sentence-b4d455de3560

tweets <- cleanedtweets %>%
  sentimentr::get_sentences() %>% 
  sentimentr::sentiment(polarity_dt = lexicon::hash_sentiment_jockers_rinker,
                        valence_shifters_dt = lexicon::hash_valence_shifters) %>% 
  group_by(element_id) %>% 
  mutate(text = add_comma_space(text)) %>% 
  mutate(tweet = paste(text, collapse=" ")) %>% 
  ungroup() %>% 
  mutate(mentiontrump = ifelse(str_detect(tweet, "Trump")==TRUE,yes=1,no=0)) %>% 
  mutate(text = replace_white(text)) %>% 
  mutate(tweet = replace_white(tweet)) %>% 
  group_by(tweet) %>% 
  mutate(tweetlevelsentiment = mean(sentiment)) %>% 
  ungroup %>% 
  filter(!is.na(word_count)) %>% 
  filter(text!=" ")  %>% 
  mutate(sentimentbinary = ifelse(sentiment>0,"Positive", 
                                  ifelse(sentiment<0,"Negative","Neutral"))) %>% 
  mutate(tweetsentimentbinary = ifelse(tweetlevelsentiment>0,"Positive",
                                       ifelse(tweetlevelsentiment<0,"Negative","Neutral"))) %>% 
  mutate(distancefromzero = abs(sentiment)) %>% 
  select(candidate, id, tweet, text, sentiment, sentimentbinary, 
         tweetlevelsentiment, tweetsentimentbinary, distancefromzero,
         favoriteCount, retweetCount, createdDate, mentiontrump,
         element_id, sentence_id, word_count)

summary(tweets)

# specific word analysis

tweet_words <- tweets %>% 
  unnest_tokens(word, text, token = "regex", pattern = reg, drop = FALSE) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]"))

# words per by candidate
candidates_words <- tweet_words %>%
  group_by(candidate) %>%
  mutate(total_words = n()) %>%
  ungroup() %>%
  distinct(candidate, total_words)

candidates_words

# merge Tweet words w/ NRC sentiment
nrc <- sentiments %>%
  filter(lexicon == "nrc") %>%
  select(word, sentiment)
colnames(nrc)[colnames(nrc)=="sentiment"] <- "wordsentiment"

tweet_words_w_nrc <- tweet_words %>%
  inner_join(nrc, by = "word")

# group sentiment by candidate
by_candidate_sentiment <- tweet_words_w_nrc %>%
  count(candidate, wordsentiment, id) %>%
  ungroup() %>%
  complete(candidate, wordsentiment, id, fill = list(n = 0)) %>%
  inner_join(candidates_words, by="candidate") %>%
  group_by(candidate, wordsentiment, total_words) %>%
  summarize(words = sum(n)) %>%
  mutate(percent = (100*(words/total_words))) %>% 
  ungroup()

by_candidate_sentiment

### PRIMARY DATASETS:
tweets
tweet_words
tweet_words_w_nrc
by_candidate_sentiment
