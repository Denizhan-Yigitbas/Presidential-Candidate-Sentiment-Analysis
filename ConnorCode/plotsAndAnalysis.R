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
library(cleanNLP)
library(textclean)
library(ggrepel)
library(topicmodels)
library(tm)
library(stm)
library(quanteda)

# tweets per candidate. these should be roughly equal
tweets_per_candidate <- tweets %>% 
  group_by(candidate) %>% 
  distinct(id, .keep_all = TRUE) %>% 
  ggplot(aes(x=forcats::fct_infreq(candidate))) +
  geom_bar() + 
  coord_flip() +
  labs(x="Count",
       y="Candidate")

tweets_per_candidate

#tweets over time
tweets_over_time <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  ggplot(aes(x=month(createdDate))) +
  geom_histogram(position = "identity", bins = 10, show.legend = FALSE) 
  
tweets_over_time  
  
# by candidate
tweets_over_time_candidate <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  ggplot(aes(x = month(createdDate), fill = candidate)) +
  geom_histogram(position = "identity", bins = 10, show.legend = FALSE) +
  facet_wrap(~candidate, scales = "free")

tweets_over_time_candidate
# takeaway: Andrew Yang Tweets way more than everyone else, 
# explaining why almost all of his tweets (1500) are from 
# the last couple months (March)

# proportional sentiment by sentence
sentimentbinary <- tweets %>% 
  ggplot(aes(x=sentimentbinary, fill=sentimentbinary)) +
  geom_bar(stat="count", show.legend = FALSE) +
  labs(x="Sentiment",
       y="Count",
       title = "Frequency of Sentiment by Sentence")

sentimentbinary

# proportional sentiment by Tweet
tweetsentimentbinary <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  ggplot(aes(x=tweetsentimentbinary, fill=tweetsentimentbinary)) +
  geom_bar(stat="count", show.legend = FALSE) +
  labs(x="Sentiment",
       y="Number of Tweets",
       title = "Frequency of Sentiment by Tweet")

tweetsentimentbinary

tweetsentimentbinary_by_candidate <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate, tweetsentimentbinary) %>% 
  summarise(n = n()) %>% 
  mutate(percentsentiment = 100*(n/sum(n))) %>% 
  ggplot(aes(x=tweetsentimentbinary, y= percentsentiment, fill=tweetsentimentbinary)) +
  geom_col(show.legend = FALSE) + 
  facet_wrap(~ candidate) +
  labs(x="Sentiment",
       y="Number of Tweets",
       title = "Frequency of Sentiment by Tweet")

tweetsentimentbinary_by_candidate

# average sentiment by candidate
candidate_sentiment <- tweets %>%
  group_by(candidate) %>% 
  summarise(sentiment = mean(sentiment)) %>% 
  arrange(desc(sentiment)) %>% 
  ggplot(aes(x = reorder(candidate, sentiment), y = sentiment, fill=candidate)) +
  geom_col(show.legend = FALSE) +
  xlab("Candidate") +
  ylab(element_blank()) +
  ggtitle("Average Sentiment by Candidate", subtitle = "With higher scores indicating more positive content")  +
  coord_flip()

candidate_sentiment

# specific emotion/wordsentiment by candidate
legend_ord <- levels(with(by_candidate_sentiment, reorder(wordsentiment, -percent)))
by_candidate_sentiment_grouped <- by_candidate_sentiment %>% 
  group_by(wordsentiment) %>% 
  ggplot(aes(x=reorder(wordsentiment,percent),y=percent, fill=wordsentiment)) +
  geom_col(show.legend=FALSE) +
  facet_wrap(~candidate) +
  ggtitle("Proportional Sentiment per Candidate") +
  xlab(element_blank())+
  ylab("Percent") +
  scale_fill_discrete(name="Sentiment", breaks = legend_ord) +
  coord_flip()

by_candidate_sentiment_grouped

# the same thing but grouped by emotion with each candidate having their own bar
by_sentiment_candidate_grouped <- by_candidate_sentiment %>% 
  group_by(candidate) %>% 
  ggplot(aes(x=candidate,y=percent, fill=candidate)) +
  geom_col() +
  theme(axis.text.x=element_blank(),axis.ticks=element_blank()) +
  facet_wrap(~wordsentiment) +
  ggtitle("Proportional Sentiment per Candidate") +
  xlab(element_blank())+
  ylab("Percent") +
  scale_fill_discrete(name="Candidate")

by_sentiment_candidate_grouped

# interaction between sentiment and Tweet favorites

polarity_vs_popularity_fav <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  filter(favoriteCount<60000) %>% 
  ggplot(aes(x=tweetlevelsentiment, y=favoriteCount)) +
  geom_point(alpha = .05) +
  geom_smooth(method=lm, se=TRUE) +
  ylab("Number of Favorites") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Favorites")

polarity_vs_popularity_fav

# grouped by candidate

polarity_vs_popularity_fav_by_candidate <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate) %>% 
  filter(favoriteCount<60000) %>% 
  ggplot(aes(x=tweetlevelsentiment, y=favoriteCount, color=candidate)) +
  geom_point(alpha = .25) +
  ylab("Number of Favorites") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Favorites", 
          subtitle = "Broken down by candidate")

polarity_vs_popularity_fav_by_candidate

# faceted

polarity_vs_popularity_fav_faceted <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate) %>% 
  filter(favoriteCount<38000) %>% 
  ggplot(aes(x=tweetlevelsentiment, y=favoriteCount)) +
  geom_point(alpha = .1) +
  facet_wrap(~candidate, scales = "free") +
  geom_smooth(method=lm) +
  ylab("Number of Favorites") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Favorites", 
          subtitle = "Faceted by candidate")

polarity_vs_popularity_fav_faceted

# and all in one plot

polarity_vs_popularity_fav_summarised <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate) %>% 
  summarise(meansentiment = mean(tweetlevelsentiment), meanfavorite=mean(favoriteCount)) %>% 
  ggplot(aes(x=meansentiment, y=meanfavorite, color=candidate)) +
  geom_point() +
  geom_label_repel(aes(label=candidate),show.legend = F) +
  ylab("Average Number of Favorites") +
  xlab("Average Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Favorites", 
          subtitle = "Per Candidate") +
  theme(legend.position = "none")

polarity_vs_popularity_fav_summarised

# interaction between wordsentiment and retweets

polarity_vs_popularity_rt <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  filter(retweetCount<30000) %>% 
  ggplot(aes(x=tweetlevelsentiment, y=retweetCount)) +
  geom_point(alpha = .1) +
  geom_smooth(method=lm) +
  ylab("Number of Retweets") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Retweets")

polarity_vs_popularity_rt

# grouped by candidate

polarity_vs_popularity_rt_by_candidate <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate) %>% 
  filter(retweetCount<30000) %>% 
  ggplot(aes(x=tweetlevelsentiment, y=retweetCount, color=candidate)) +
  geom_point(alpha = .1) +
  ylab("Number of Retweets") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Retweets",
          subtitle = "Broken down by candidate")

polarity_vs_popularity_rt_by_candidate

# faceted

polarity_vs_popularity_rt_faceted <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate) %>% 
  filter(retweetCount<30000) %>% 
  ggplot(aes(x=tweetlevelsentiment, y=retweetCount)) +
  geom_point(alpha = .1) +
  facet_wrap(~candidate, scales = "free") +
  geom_smooth(method=lm) +
  ylab("Number of Retweets") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Retweets",
          subtitle = "Faceted by candidate")

polarity_vs_popularity_rt_faceted

# and all in one plot

polarity_vs_popularity_rt_summarised <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate) %>% 
  summarise(meansentiment = mean(tweetlevelsentiment), meanretweet=mean(retweetCount)) %>% 
  ggplot(aes(x=meansentiment, y=meanretweet, color=candidate)) +
  geom_point() +
  geom_label_repel(aes(label=candidate),show.legend = F) +
  ylab("Average Number of Retweets") +
  xlab("Average Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Retweets",
          subtitle = "Per candidate") +
  theme(legend.position = "none")

polarity_vs_popularity_rt_summarised

polarity_vs_popularity <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  mutate(interactions = favoriteCount + retweetCount) %>% 
  filter(interactions < 90000) %>% 
  filter(sentiment<1.5) %>% 
  ggplot(aes(x=tweetlevelsentiment, y=interactions)) +
  geom_point(alpha = .05) +
  geom_smooth(method=lm, se=TRUE) +
  ylab("Number of Interactions") +
  xlab("Sentiment Score") +
  ggtitle("Relationship Between Tweet Sentiment and Interactions")

polarity_vs_popularity

# average retweets and favs by candidate
retweetspertweet <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate, id) %>% 
  summarise(rts = first(retweetCount)) %>% 
  group_by(candidate) %>% 
  summarise(rtspertweet = (sum(rts)/n()))

retweetspertweet %>% 
  ggplot(aes(x=reorder(candidate, rtspertweet),y=rtspertweet, fill = candidate)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(y="Average Retweets per Tweet",
       x=element_blank())

favoritespertweet <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate, id) %>% 
  summarise(favs = first(favoriteCount)) %>% 
  group_by(candidate) %>% 
  summarise(favspertweet = (sum(favs)/n()))

favoritespertweet %>% 
  ggplot(aes(x=reorder(candidate, favspertweet),y=favspertweet, fill = candidate)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(y="Average Favorites per Tweet",
       x=element_blank())

# determine which words are associated with greater
# numbers of favorites and retweets
# https://www.tidytextmining.com/twitter.html#favorites-and-retweets

word_by_rts <- tweet_words %>% 
  group_by(id, word, candidate) %>% 
  summarise(rts = first(retweetCount)) %>% 
  group_by(candidate, word) %>% 
  summarise(retweets = median(rts), uses = n()) %>%
  ungroup()

word_by_rts %>% 
  filter(uses > 5) %>%
  arrange(desc(retweets))

word_by_rts %>%
  filter(uses > 5) %>%
  group_by(candidate) %>%
  top_n(10, retweets) %>%
  arrange(retweets) %>%
  ungroup() %>%
  mutate(word = factor(word, unique(word))) %>%
  ungroup() %>%
  ggplot(aes(word, retweets, fill = candidate)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ candidate, scales = "free") +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of Retweets for Tweets containing each word")

word_by_favs <- tweet_words %>% 
  group_by(id, word, candidate) %>% 
  summarise(favs = first(favoriteCount)) %>% 
  group_by(candidate, word) %>% 
  summarise(favorites = median(favs), uses = n()) %>%
  left_join(favoritespertweet) %>%
  filter(favorites != 0) %>%
  ungroup()

word_by_favs %>% 
  filter(uses > 5) %>%
  arrange(desc(favorites))

word_by_favs %>%
  filter(uses > 5) %>%
  group_by(candidate) %>%
  top_n(10, favorites) %>%
  arrange(favorites) %>%
  ungroup() %>%
  mutate(word = factor(word, unique(word))) %>%
  ungroup() %>%
  ggplot(aes(word, favorites, fill = candidate)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ candidate, scales = "free") +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of Favorites for Tweets containing each word")

word_by_interactions <- tweet_words %>% 
  group_by(id, word, candidate) %>% 
  mutate(interactions = favoriteCount+retweetCount) %>% 
  summarise(interactions = first(interactions)) %>% 
  group_by(candidate, word) %>% 
  summarise(interactions = median(interactions), uses = n()) %>%
  filter(interactions != 0) %>%
  ungroup()

word_by_interactions %>%
  filter(uses > 5) %>%
  group_by(candidate) %>%
  top_n(10, interactions) %>%
  arrange(interactions) %>%
  ungroup() %>%
  mutate(word = factor(word, unique(word))) %>%
  ungroup() %>%
  ggplot(aes(word, interactions, fill = candidate)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ candidate, scales = "free") +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of Interactions for Tweets containing each word")

word_by_interactions %>%
  filter(uses > 5) %>%
  top_n(10, interactions) %>%
  arrange(interactions) %>%
  ungroup() %>%
  mutate(word = factor(word, unique(word))) %>%
  ungroup() %>%
  ggplot(aes(word, interactions)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  labs(x = NULL, 
       y = "Median # of Interactions for Tweets containing each word")

# note for above: look at Joe Biden's repeated use of the phrase "battle for the soul of this nation" lol
# https://twitter.com/search?q=battle%20from%3AJoeBiden&src=typd

# related to above, plot favs/RTs according to specific wordsentiment (e.g does anger sell?)

candidate_retweets_by_sentiment <- tweet_words_w_nrc %>%
  group_by(id, wordsentiment, candidate) %>% 
  summarise(rts = first(retweetCount)) %>% 
  group_by(candidate, wordsentiment) %>% 
  summarise(retweets = mean(rts), uses = n()) %>% 
  ungroup()

# broken down by candidate
candidate_retweets_by_sentiment %>% 
  group_by(candidate) %>% 
  ggplot(aes(x=reorder(wordsentiment, retweets), y=retweets, fill=wordsentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ candidate, scales = "free") +
  coord_flip() +
  ylab("Average # of Retweets") +
  xlab(element_blank()) +
  ggtitle("Popularity of Tweet Sentiments")

#combined  
candidate_retweets_by_sentiment %>% 
  group_by(wordsentiment) %>% 
  summarise(meanretweets = mean(retweets)) %>% 
  ggplot(aes(x=reorder(wordsentiment, meanretweets), y=meanretweets, fill=wordsentiment)) +
  geom_col(show.legend = FALSE) +
  coord_flip()+
  ylab("Average # of Retweets") +
  xlab(element_blank()) +
  ggtitle("Popularity of Tweet Sentiments")

candidate_favorites_by_sentiment <- tweet_words_w_nrc %>%
  group_by(id, wordsentiment, candidate) %>% 
  summarise(favs = first(favoriteCount)) %>% 
  group_by(candidate, wordsentiment) %>% 
  summarise(favorites = mean(favs), uses = n()) %>% 
  ungroup() 

candidate_favorites_by_sentiment %>% 
  group_by(candidate) %>% 
  ggplot(aes(x=reorder(wordsentiment, favorites), y=favorites, fill=wordsentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ candidate, scales = "free") +
  coord_flip() +
  ylab("Average # of Favorites") +
  xlab(element_blank()) +
  ggtitle("Popularity of Tweet Sentiments")

candidate_favorites_by_sentiment %>% 
  group_by(wordsentiment) %>% 
  summarise(meanfavorites = mean(favorites)) %>% 
  ggplot(aes(x=reorder(wordsentiment, meanfavorites), y=meanfavorites, fill=wordsentiment)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  ylab("Average # of Favorites") +
  xlab(element_blank()) +
  ggtitle("Popularity of Tweet Sentiments")

candidate_interactions_by_sentiment <- tweet_words_w_nrc %>%
  group_by(id, wordsentiment, candidate) %>% 
  mutate(interactions = favoriteCount+retweetCount) %>% 
  summarise(interactions = first(interactions)) %>% 
  group_by(candidate, wordsentiment) %>% 
  summarise(interactions = mean(interactions), uses = n()) %>% 
  ungroup() 

candidate_interactions_by_sentiment %>% 
  group_by(candidate) %>% 
  ggplot(aes(x=reorder(wordsentiment, interactions), y=interactions, fill=wordsentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ candidate, scales = "free") +
  coord_flip() +
  ylab("Average # of Interactions") +
  xlab(element_blank()) +
  ggtitle("Popularity of Tweet Sentiments")

candidate_interactions_by_sentiment %>% 
  group_by(wordsentiment) %>% 
  summarise(meaninteractions = mean(interactions)) %>% 
  ggplot(aes(x=reorder(wordsentiment, meaninteractions), y=meaninteractions, fill=wordsentiment)) +
  geom_col(show.legend = FALSE) +
  coord_flip() +
  ylab("Average # of Interactions") +
  xlab(element_blank()) +
  ggtitle("Popularity of Tweet Sentiments")

## Major Takeaway: Negative sentiments--like disgust, anger, sadness, and fear sell.
## These emotions garner more retweets and favorites than positive sentiments

# Differences in wordsentiment between Tweets mentioning Trump and not

sentiment_by_trump_mention <- tweets %>% 
  group_by(mentiontrump) %>% 
  summarise(meansentiment = mean(sentiment)) %>% 
  ggplot(aes(x=mentiontrump, y=meansentiment, fill=mentiontrump)) +
  geom_col(show.legend = FALSE) +
  ggtitle("Average Sentiment", subtitle = "Tweets that mention Trump vs those that don't") +
  ylab("Sentiment") +
  xlab(element_blank()) +
  scale_x_continuous(breaks=c(0,1), labels = c("Does Not Mention", "Does Mention"))
  
sentiment_by_trump_mention

# Who is most likely to mention Trump?

tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate) %>% 
  summarise(mentiontrump = sum(mentiontrump==1), 
            totaltweets = n(), 
            percent = 100*(mentiontrump/totaltweets)) %>% 
  ggplot(aes(x=reorder(candidate, percent), y=percent, fill = candidate)) +
  geom_col(show.legend = FALSE) + 
  xlab(element_blank()) +
  ylab("Percent of Tweets Mentioning Trump") +
  ggtitle("Candidate Frequency of Mentioning Trump") +
  coord_flip()

# To do: How does wordsentiment change when Tweets mention Trump?

trump_w_sentiment <- tweet_words_w_nrc %>% 
  mutate(mentiontrump = as.factor(mentiontrump)) %>% 
  group_by(mentiontrump, wordsentiment) %>% 
  summarise(n = n()) %>% 
  mutate(percentsentiment = 100*(n/sum(n))) %>% 
  ggplot(aes(group=mentiontrump, x=reorder(wordsentiment,percentsentiment), 
             fill=mentiontrump, y=percentsentiment)) +
  geom_bar(position=position_dodge(), stat="identity") +
  scale_fill_discrete(name="Mentions Trump",
                    breaks=c(0,1),
                    labels=c("No", "Yes")) +
  labs(x=element_blank(), 
       y = "Proportion of Words", 
       title = "Sentiment as a Proportion of Overall Tweets", 
       subtitle = "Comparing Tweets mentioning Trump with those that don't")
  
trump_w_sentiment
  
# To do: plot relationship between current polling numbers and Tweet wordsentiment/favs/rts/etc.
# nvm this analysis is stupid
poll_vs_tweets <- tweets %>% 
  group_by(polling) %>% 
  summarise(favoriteCount = mean(favoriteCount)) %>% 
  ggplot(aes(x=polling, y=favoriteCount)) +
  geom_point() +
  geom_smooth(method=lm, se=FALSE)

poll_vs_tweets

tweet_words_w_nrc %>% 
group_by(polling, wordsentiment) %>% 
  summarise(n = n()) %>% 
  mutate(percentsentiment = 100*(n/sum(n))) %>% 
  ggplot(aes(x=polling, y=percentsentiment)) +
  geom_point() +
  facet_wrap(~ wordsentiment, scales = "free")
  

# To do: does mentioning trump affect affect retweets/favs?
# see https://www-sciencedirect-com.ezproxy.rice.edu/science/article/pii/S2468696417301088#fig0010

trump_w_favs <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  mutate(mentiontrump = as.factor(mentiontrump)) %>% 
  group_by(mentiontrump) %>% 
  summarise(favoriteCount = mean(favoriteCount)) %>% 
  ggplot(aes(x=mentiontrump, y=favoriteCount, fill=mentiontrump)) +
  geom_col(show.legend = FALSE) +
  scale_x_discrete(breaks=c(0,1), labels = c("Does Not Mention", "Does Mention")) +
  labs(x="Mentions Trump",
       y = "Average # of Favorites", 
       title = "Average Tweet Popularity", 
       subtitle = "Comparing Tweets mentioning Trump with those that don't") 

trump_w_favs

trump_w_rts <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  mutate(mentiontrump = as.factor(mentiontrump)) %>% 
  group_by(mentiontrump) %>% 
  summarise(retweetCount = mean(retweetCount)) %>% 
  ggplot(aes(x=mentiontrump, y=retweetCount, fill=mentiontrump)) +
  geom_col(show.legend = FALSE) +
  scale_x_discrete(breaks=c(0,1), labels = c("Does Not Mention", "Does Mention")) +
  labs(x="Mentions Trump",
       y = "Average # of Favorites", 
       title = "Average Tweet Popularity", 
       subtitle = "Comparing Tweets mentioning Trump with those that don't") 

trump_w_rts

trump_w_interactions <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  mutate(interactions = retweetCount+favoriteCount) %>% 
  mutate(mentiontrump = as.factor(mentiontrump)) %>% 
  group_by(mentiontrump) %>% 
  summarise(interactions = mean(interactions)) %>% 
  ggplot(aes(x=mentiontrump, y=interactions, fill=mentiontrump)) +
  geom_col(show.legend = FALSE) +
  scale_x_discrete(breaks=c(0,1), labels = c("Does Not Mention", "Does Mention")) +
  labs(x="Mentions Trump",
       y = "Average # of Interactions", 
       title = "Average Tweet Popularity", 
       subtitle = "Comparing Tweets mentioning Trump with those that don't") 

trump_w_interactions

# how often do candidates talk about women's issues?
women_tweets <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  filter(str_detect(tweet, "women")==TRUE) %>% 
  group_by(candidate) %>% 
  summarise(n = n()) %>%  
  ggplot(aes(x=reorder(candidate, n), y=n, fill = candidate)) +
  geom_col(show.legend=FALSE) +
  ggtitle("Candidate Mentions of the Word 'Women'") +
  xlab(element_blank()) +
  ylab("Mentions")  +
  coord_flip()

women_tweets