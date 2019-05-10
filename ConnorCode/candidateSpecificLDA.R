### TRASH? DO NOT USE
### STEP SIX: Topic Modeling by Candidate

amyklobuchar <- subset(tweet_words, candidate=="Amy Klobuchar")
andrewyang <- subset(tweet_words, candidate=="Andrew Yang")
berniesanders <- subset(tweet_words, candidate=="Bernie Sanders")
betoorourke <- subset(tweet_words, candidate=="Beto O'Rourke")
corybooker <- subset(tweet_words, candidate=="Cory Booker")
elizabethwarren <- subset(tweet_words, candidate=="Elizabeth Warren")
joebiden <- subset(tweet_words, candidate=="Joe Biden")
juliancastro <- subset(tweet_words, candidate=="Julian Castro")
kamalaharris <- subset(tweet_words, candidate=="Kamala Harris")
kirstengillibrand <- subset(tweet_words, candidate=="Kirsten Gillibrand")
petebuttigieg <- subset(tweet_words, candidate=="Pete Buttigieg")
tulsigabbard <- subset(tweet_words, candidate=="Tulsi Gabbard")

klobuchar_lda <- amyklobuchar %>% 
  count(id, word, sort = TRUE) %>% 
  bind_tf_idf(word, id, n)

klobuchar_lda

klobuchar_relative_freq <- klobuchar_lda %>% 
  ungroup %>% 
  mutate(word=reorder(word,n)) %>% 
  ggplot(aes(x=word, y=n)) +
  geom_col(show.legend = FALSE)

klobuchar_relative_freq

klobuchar_dfm <- klobuchar_lda %>% 
  cast_dfm(candidate, word, n)

# topic modeling
klobuchar_topic_model <- stm(klobuchar_dfm, K = 6, init.type = "Spectral")
summary(klobuchar_topic_model)

klobuchar_tidy_tm <- tidy(klobuchar_topic_model)
klobuchar_tidy_tm %>% 
  group_by(topic) %>% 
  top_n(10) %>% 
  ungroup %>% 
  mutate(term = reorder(term, beta)) %>% 
  ggplot(aes(x=term, y=beta, fill=topic)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~topic, scales="free") +
  coord_flip()
