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

## The following differs from most sentiment analysis in that it looks at 
## sentence level data instead of word-level
## this is preferable due to valence shifters 
# reference https://blog.exploratory.io/twitter-sentiment-analysis-scoring-by-sentence-b4d455de3560

# add sentiment per tweet, move sentiment and tweet text to front of dataset
tweets_w_sentiment <- tweets %>% 
  mutate(sentiment = get_sentiment(text)) %>% 
  select(sentiment, polarity, text, everything())

# extract the keywords responsible for sentiment coding??
# below is not working; i need it to keep candidate name but its extracitng sentiment terms and keeping nothing else
#tweets_w_sentiment <- tweets_w_sentiment %>% 
 # mutate(keywords <- extract_sentiment_terms(tweets$text, polarity_dt = lexicon::hash_sentiment_jockers_rinker))

# sentiment_terms <- extract_sentiment_terms(tweets$text, polarity_dt = lexicon::hash_sentiment_jockers_rinker)

# average sentiment by candidate
candidate_sentiment <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  summarise(sentiment = mean(sentiment)) %>% 
  arrange(desc(sentiment)) %>% 
  ggplot(aes(x = reorder(candidate, sentiment), y = sentiment, fill=candidate)) +
  geom_col()

candidate_sentiment

# specific word analysis

tweet_words <- tweets %>% 
  unnest_tokens(word, text, token = "regex", pattern = reg) %>%
  filter(!word %in% stop_words$word,
         str_detect(word, "[a-z]"))

candidates_words <- tweet_words %>%
  group_by(candidate) %>%
  mutate(total_words = n()) %>%
  ungroup() %>%
  distinct(id, candidate, total_words)

nrc <- sentiments %>%
  filter(lexicon == "nrc") %>%
  dplyr::select(word, sentiment)

by_candidate_sentiment <- tweet_words %>%
  inner_join(nrc, by = "word") %>%
  count(sentiment, id) %>%
  ungroup() %>%
  complete(sentiment, id, fill = list(n = 0)) %>%
  inner_join(candidates_words) %>%
  group_by(candidate, sentiment, total_words) %>%
  summarize(words = sum(n)) %>%
  mutate(percent = words/total_words) %>% 
  ungroup()

head(by_candidate_sentiment)
## what the above tells us is a candidates' tweets' proportion of words that are of a certain sentiment
# e.g. 3.96% of Amy Klobuchar's "Tweet words" are angry, 6.93% are in anticipation, etc.

# specific emotion/sentiment by candidate
by_candidate_sentiment_grouped <- by_candidate_sentiment %>% 
  group_by(sentiment) %>% 
ggplot(aes(x=reorder(sentiment,percent),y=percent, fill=sentiment)) +
  geom_col() +
  theme(axis.text.x=element_blank(),axis.ticks=element_blank()) +
  facet_wrap(~candidate) +
  ggtitle("Proportional Sentiment per Candidate") +
  xlab(element_blank())+
  ylab("Percent")

by_candidate_sentiment_grouped

# the same thing but grouped by emotion with each candidate having their own bar
by_sentiment_candidate_grouped <- by_candidate_sentiment %>% 
  group_by(candidate) %>% 
  ggplot(aes(x=candidate,y=percent, fill=candidate)) +
  geom_col() +
  theme(axis.text.x=element_blank(),axis.ticks=element_blank()) +
  facet_wrap(~sentiment) +
  ggtitle("Proportional Sentiment per Candidate") +
  xlab(element_blank())+
  ylab("Percent")

by_sentiment_candidate_grouped

# interaction between sentiment and Tweet interactions

polarity_vs_popularity <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  filter(favoriteCount<60000) %>% 
  ggplot(aes(x=sentiment, y=favoriteCount, color=candidate)) +
  geom_point() +
  geom_smooth(method=lm, se=FALSE)

polarity_vs_popularity

