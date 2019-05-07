### USE THIS ONCE DATA IS CLEANED AND
### DATA IS ALL IN ONE SHEET

## The following differs from most sentiment analysis in that it looks at 
## sentence level data instead of word-level
## this is preferable due to valence shifters 
# reference https://blog.exploratory.io/twitter-sentiment-analysis-scoring-by-sentence-b4d455de3560

# add sentiment per tweet
tweets_w_sentiment <- tweets %>% 
  mutate(sentiment = get_sentiment(text))

# move sentiment and tweet text to front of dataset
tweets_w_sentiment <- tweets_w_sentiment %>% 
  select(sentiment, text, everything())

# extract the keywords responsible for sentiment coding??
tweets_w_sentiment <- tweets_w_sentiment %>% 
  mutate(extract_sentiment_terms())

# average sentiment by candidate
candidate_sentiment <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  summarise(sentiment = mean(sentiment))
