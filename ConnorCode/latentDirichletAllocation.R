# note most of this script is trash i think
### STEP FIVE: Topic Modeling (using LDA)
### Reference https://eight2late.wordpress.com/2015/09/29/a-gentle-introduction-to-topic-modeling-using-r/
### Reference https://www.tidytextmining.com/topicmodeling.html

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

# tf_idf for candidates' tweets
# "people" filtered out due to high n's
tweets_lda <- tweet_words %>% 
  count(candidate, word, sort = TRUE) %>%
  bind_tf_idf(word, candidate, n) %>% 
  group_by(candidate)

tweets_lda

# this plots candidates' words which are of most relative importance compared to other candidate
relative_freq <- tweets_lda %>% 
  filter(word!="people") %>% 
  top_n(10) %>% 
  ungroup %>% 
  mutate(word=reorder(word,tf_idf)) %>% 
  ggplot(aes(x=word, y=tf_idf, fill=candidate)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~candidate, scales="free") +
  coord_flip() +
  xlab(element_blank()) +
  ylab(element_blank()) +
  ggtitle("Most Frequently Used Words on Twitter", 
          subtitle = "Relative to Other Candidates")

relative_freq

# create a document term matrix
tweets_dtm <- tweets_lda %>% 
  cast_dtm(candidate, word, n)

# LDA
real_tweets_lda <- LDA(tweets_dtm, k = 12, control = list(seed = 1234))

#per candidate words
candidate_topics <- tidy(real_tweets_lda, matrix = "beta")
candidate_topics

#top terms
top_terms <- candidate_topics %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(term = reorder(term, beta)) %>%
  ggplot(aes(term, beta, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  coord_flip() +
  xlab("Proportion of Topic") +
  ylab(element_blank()) +
  ggtitle("Distinct Topic Categories", 
          subtitle = "Using Latent Dirichlet Allocation")

#per candidate classification
candidate_gamma <- tidy(real_tweets_lda, matrix = "gamma")
candidate_gamma

candidate_gamma %>%
  mutate(document = reorder(document, gamma * topic)) %>%
  ggplot(aes(factor(topic), gamma)) +
  geom_boxplot() +
  facet_wrap(~ document) +
  xlab("Topic Category") +
  ylab(element_blank()) +
  ggtitle("Proportion of Candidate Tweets Assigned to a Topic Category")

#classify candidate tweets
candidate_classifications <- candidate_gamma %>%
  group_by(document) %>%
  top_n(1, gamma) %>%
  ungroup()

candidate_topics <- candidate_classifications %>%
  count(document, topic) %>%
  group_by(document) %>%
  top_n(1, n) %>%
  ungroup() %>%
  transmute(consensus = document, topic)

#assignments
assignments <- augment(real_tweets_lda, data = tweets_dtm)
assignments

assignments <- assignments %>%
  inner_join(candidate_topics, by = c(".topic" = "topic"))

assignments

# the matching of document and consensus allows us to explore how well 
# the model paired candidates with predicted word choice

assignments %>%
  count(document, consensus, wt = count) %>%
  group_by(document) %>%
  mutate(percent = n / sum(n)) %>%
  ggplot(aes(consensus, document, fill = percent)) +
  geom_tile() +
  scale_fill_gradient2(high = "red", label = percent_format()) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        panel.grid = element_blank()) +
  labs(x = "Candidates words were assigned to",
       y = "Candidates words came from",
       fill = "% of assignments") +
  ggtitle("Model Accuracy")

# Testing the accuracy of the model by showing the relationship between 
# word assignment to a given candidate and actual word usage. 
# Takeaways: Kamala Harris’ tweet words were often predicted to be 
# from Cory Booker, Cory Booker's tweets were often predicted to be
# from Andrew Yang, and Joe Biden and Julian Castro often got mixed up

#which words were wrong?
wrong_words <- assignments %>%
  filter(document != consensus)

wrong_words %>%
  filter(document!="Cory Booker" & document!="Julian Castro") %>% 
  count(document, consensus, term, wt = count) %>%
  ungroup() %>%
  arrange(desc(n)) %>% 
  top_n(20) %>% 
  ggplot(aes(term, n, fill=consensus)) +
  geom_col() +
  facet_wrap(~document, scales = "free") +
  ggtitle("Predicted vs Actual Source of Tweet Word") +
  xlab("Term") +
  ylab("Frequency") +
  labs(fill="Predicted Candidate")
