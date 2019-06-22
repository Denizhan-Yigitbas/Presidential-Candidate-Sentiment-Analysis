### STEP FOUR: REGRESSION AND STATISTICS STUFF
### TO DO ONCE EDA IS COMPLETED AND SENTIMENT HAS BEEN COMPUTED
### Reference https://stats.idre.ucla.edu/r/dae/poisson-regression/

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

# do poisson regression, not sure how though lol 
# also reference http://varianceexplained.org/r/trump-tweets/
sentiment_differences <- tweets %>%
  distinct(id, .keep_all = TRUE) %>% 
  group_by(candidate) %>%
  do(tidy(poisson.test(tweets$candidate, tweets$sentiment)))

sentiment_differences

# interaction between sentiment and favs/rts
tweets_w_no_sentences <- tweets %>% 
  distinct(id, .keep_all = TRUE) %>% 
  mutate(interactions = favoriteCount + retweetCount)
  
summary(lm(interactions ~ distancefromzero, data=tweets_w_no_sentences))
summary(lm(interactions ~ sentiment, data=tweets_w_no_sentences))
summary(lm(favoriteCount ~ sentiment, data=tweets_w_no_sentences))
summary(lm(retweetCount ~ sentiment, data=tweets_w_no_sentences))

summary(m1 <- glm(interactions ~ tweetlevelsentiment, family="poisson", data=tweets))
tweets$phat <- predict(m1, type="response")
tweets <- tweets[with(tweets, order(tweetlevelsentiment)), ]

tweets %>% 
  distinct(id, .keep_all=TRUE) %>% 
  ggplot(aes(x = tweetlevelsentiment, y = phat)) +
  geom_point(aes(y = interactions), alpha=.05) +
  geom_line(size = 1) +
  labs(x = "Sentiment", y = "Tweet Interactions") +
  xlim(c(-1,1)) +
  ylim(c(0,25000))
