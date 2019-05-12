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

## The following differs from most sentiment analysis in that it looks at 
## sentence level data instead of word-level
## this is preferable due to valence shifters 
# reference https://blog.exploratory.io/twitter-sentiment-analysis-scoring-by-sentence-b4d455de3560

# add sentiment per tweet, move sentiment and tweet text to front of dataset
# get_sentiment is from the syuzhet package, and by default uses the syuzhet dictionary
# mutate: variable for Tweets mentioning Trump and not 
tweets <- tweets %>% 
  mutate(sentimentscale = get_sentiment(text)) %>% 
  mutate(mentiontrump = ifelse(str_detect(tweets$text, "Trump")==TRUE,yes=1,no=0)) %>% 
  select(-c(polarity)) %>% 
  select(sentimentscale, text, everything())

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
  dplyr::select(word, sentiment)

tweet_words <- tweet_words %>%
  inner_join(nrc, by = "word")

# group sentiment by candidate
by_candidate_sentiment <- tweet_words %>%
  count(candidate, sentiment, id) %>%
  ungroup() %>%
  complete(candidate, sentiment, id, fill = list(n = 0)) %>%
  inner_join(candidates_words, by="candidate") %>%
  group_by(candidate, sentiment, total_words) %>%
  summarize(words = sum(n)) %>%
  mutate(percent = (100*(words/total_words))) %>% 
  ungroup()

by_candidate_sentiment

### PRIMARY DATASETS:
tweets
tweet_words
by_candidate_sentiment
