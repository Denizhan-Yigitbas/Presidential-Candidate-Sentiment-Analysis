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
tweets_w_sentiment <- tweets %>% 
  mutate(sentiment = get_sentiment(text)) %>% 
  select(sentiment, text, everything())

# extract the keywords responsible for sentiment coding??
# below is not working; i need it to keep candidate name but its extracitng sentiment terms and keeping nothing else
# tweets_w_sentiment <- tweets_w_sentiment %>% 
 # mutate(keywords <- extract_sentiment_terms(tweets$text, polarity_dt = lexicon::hash_sentiment_jockers_rinker))

# sentiment_terms <- extract_sentiment_terms(tweets$text, polarity_dt = lexicon::hash_sentiment_jockers_rinker)

# specific word analysis

tweet_words <- tweets %>% 
  unnest_tokens(word, text, token = "regex", pattern = reg) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]"))

tweet_words
candidates_words <- tweet_words %>%
  group_by(candidate) %>%
  mutate(total_words = n()) %>%
  ungroup() %>%
  distinct(candidate, total_words)

candidates_words

nrc <- sentiments %>%
  filter(lexicon == "nrc") %>%
  dplyr::select(word, sentiment)

tweet_words_w_sentiment <- tweet_words %>%
  inner_join(nrc, by = "word")

tweet_words_w_sentiment

by_candidate_sentiment <- tweet_words %>%
  inner_join(nrc, by = "word") %>%
  count(candidate, sentiment, id) %>%
  ungroup() %>%
  complete(candidate, sentiment, id, fill = list(n = 0)) %>%
  inner_join(candidates_words, by="candidate") %>%
  group_by(candidate, sentiment, total_words) %>%
  summarize(words = sum(n)) %>%
  mutate(percent = (100*(words/total_words))) %>% 
  ungroup()

by_candidate_sentiment
