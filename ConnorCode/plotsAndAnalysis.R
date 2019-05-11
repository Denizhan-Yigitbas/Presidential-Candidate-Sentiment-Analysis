### STEP THREE: EXPLORATORY PLOTS

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
library(ggrepel)

# tweets per candidate. these should be roughly equal
tweets_per_candidate <- tweets_w_sentiment %>% 
  group_by(candidate) %>% 
  ggplot(aes(x=candidate)) +
  geom_bar() 

tweets_per_candidate

#tweets over time
tweets_over_time <- tweets %>% 
  ggplot(aes(x=month(createdDate))) +
  geom_histogram(position = "identity", bins = 10, show.legend = FALSE)
  
tweets_over_time  
  
# by candidate
ggplot(tweets, aes(x = month(createdDate), fill = candidate)) +
  geom_histogram(position = "identity", bins = 10, show.legend = FALSE) +
  facet_wrap(~candidate, scales = "free")

# takeaway: Andrew Yang Tweets way more than everyone else, 
# explaining why almost all of his tweets (1500) are from 
# the last couple months (March)

# average sentiment by candidate
candidate_sentiment <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  summarise(sentiment = mean(sentiment)) %>% 
  arrange(desc(sentiment)) %>% 
  ggplot(aes(x = reorder(candidate, sentiment), y = sentiment, fill=candidate)) +
  geom_col(show.legend = FALSE) +
  xlab("Candidate") +
  ylab(element_blank()) +
  ggtitle("Average Sentiment by Candidate", subtitle = "With higher scores indicating more positive content") 

candidate_sentiment

# specific emotion/sentiment by candidate
legend_ord <- levels(with(by_candidate_sentiment, reorder(sentiment, -percent)))
by_candidate_sentiment_grouped <- by_candidate_sentiment %>% 
  group_by(sentiment) %>% 
  ggplot(aes(x=reorder(sentiment,percent),y=percent, fill=sentiment)) +
  geom_col() +
  theme(axis.text.x=element_blank(),axis.ticks=element_blank()) +
  facet_wrap(~candidate) +
  ggtitle("Proportional Sentiment per Candidate") +
  xlab(element_blank())+
  ylab("Percent") +
  scale_fill_discrete(name="Sentiment", breaks = legend_ord)

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
  ylab("Percent") +
  scale_fill_discrete(name="Candidate")

by_sentiment_candidate_grouped

# interaction between sentiment and Tweet favorites

polarity_vs_popularity_fav <- tweets_w_sentiment %>%
  filter(favoriteCount<60000) %>% 
  ggplot(aes(x=sentiment, y=favoriteCount)) +
  geom_point(alpha = .05) +
  geom_smooth(method=lm) +
  ylab("Number of Favorites") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Favorites")

polarity_vs_popularity_fav

# grouped by candidate

polarity_vs_popularity_fav_by_candidate <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  filter(favoriteCount<60000) %>% 
  ggplot(aes(x=sentiment, y=favoriteCount, color=candidate)) +
  geom_point(alpha = .25) +
  ylab("Number of Favorites") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Favorites", 
          subtitle = "Broken down by candidate")

polarity_vs_popularity_fav_by_candidate

# faceted

polarity_vs_popularity_fav_faceted <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  filter(favoriteCount<38000) %>% 
  ggplot(aes(x=sentiment, y=favoriteCount)) +
  geom_point(alpha = .1) +
  facet_wrap(~candidate, scales = "free") +
  geom_smooth(method=lm) +
  ylab("Number of Favorites") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Favorites", 
          subtitle = "Faceted by candidate")

polarity_vs_popularity_fav_faceted

# and all in one plot

polarity_vs_popularity_fav_summarised <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  summarise(meansentiment = mean(sentiment), meanfavorite=mean(favoriteCount)) %>% 
  ggplot(aes(x=meansentiment, y=meanfavorite, color=candidate)) +
  geom_point() +
  geom_label_repel(aes(label=candidate),show.legend = F) +
  ylab("Average Number of Favorites") +
  xlab("Average Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Favorites", 
          subtitle = "Per Candidate") +
  theme(legend.position = "none")

polarity_vs_popularity_fav_summarised

# interaction between sentiment and retweets

polarity_vs_popularity_rt <- tweets_w_sentiment %>%
  filter(retweetCount<38000) %>% 
  ggplot(aes(x=sentiment, y=retweetCount)) +
  geom_point(alpha = .1) +
  geom_smooth(method=lm) +
  ylab("Number of Retweets") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Retweets")

polarity_vs_popularity_rt

# grouped by candidate

polarity_vs_popularity_rt_by_candidate <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  filter(retweetCount<38000) %>% 
  ggplot(aes(x=sentiment, y=retweetCount, color=candidate)) +
  geom_point(alpha = .25) +
  ylab("Number of Retweets") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Retweets",
          subtitle = "Broken down by candidate")

polarity_vs_popularity_rt_by_candidate

# faceted

polarity_vs_popularity_rt_faceted <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  filter(retweetCount<30000) %>% 
  ggplot(aes(x=sentiment, y=retweetCount)) +
  geom_point(alpha = .1) +
  facet_wrap(~candidate) +
  geom_smooth(method=lm) +
  ylab("Number of Retweets") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Retweets",
          subtitle = "Faceted by candidate")

polarity_vs_popularity_rt_faceted

# and all in one plot

polarity_vs_popularity_rt_summarised <- tweets_w_sentiment %>%
  group_by(candidate) %>% 
  summarise(meansentiment = mean(sentiment), meanretweet=mean(retweetCount)) %>% 
  ggplot(aes(x=meansentiment, y=meanretweet, color=candidate)) +
  geom_point() +
  geom_label_repel(aes(label=candidate),show.legend = F) +
  ylab("Average Number of Retweets") +
  xlab("Average Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Retweets",
          subtitle = "Per candidate") +
  theme(legend.position = "none")

polarity_vs_popularity_rt_summarised

# To do: determine which words are associated with greater
# numbers of favorites and retweets
# https://www.tidytextmining.com/twitter.html#favorites-and-retweets

# related to above, plot favs/RTs according to specific sentiment (e.g does anger sell?)

# To do: plot relationship between current polling numbers and 
# Tweet sentiment/favs/rts/etc.

# To do: who is most likely to mention Trump? etc.

# sentiment grouped by Tweets mentioning Trump and not 
tweets_mention_trump_w_sentiment <- tweets_w_sentiment %>% 
  mutate(mentiontrump = ifelse(str_detect(tweets_w_sentiment$text, "Trump")==TRUE,yes=1,no=0))

sentiment_by_trump_mention <- tweets_mention_trump_w_sentiment %>% 
  group_by(mentiontrump) %>% 
  summarise(meansentiment = mean(sentiment)) %>% 
  ggplot(aes(x=mentiontrump, y=meansentiment, fill=mentiontrump)) +
  geom_col(show.legend = FALSE) +
  ggtitle("Average Sentiment", subtitle = "Tweets that mention 'Trump' vs those that don't") +
  ylab("Sentiment") +
  xlab(element_blank()) +
  scale_x_continuous(breaks=c(0,1), labels = c("Does Not Mention", "Does Mention"))
  
sentiment_by_trump_mention
