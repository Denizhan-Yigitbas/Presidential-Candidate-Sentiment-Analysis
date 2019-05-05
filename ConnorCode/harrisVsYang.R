testbind <- rbind(harris,yang)

testbind2 <- rbind(harris_by_source_sentiment,yang_by_source_sentiment)

testbind2

bindviz <- testbind2 %>% 
  group_by(candidate, sentiment) %>% 
  mutate(percent = words/total_words) %>% 
  summarise(mean=mean(percent)) %>% 
  ggplot(aes(x=reorder(sentiment,mean),y=mean)) +
  geom_col() +
  coord_flip()

bindviz

# word by candidate, log ratios 
tweet_words_bind <- rbind(yang_tweet_words, harris_tweet_words)

yangvharrisratio <- tweet_words_bind %>%
  count(word, candidate) %>%
  filter(sum(n) >= 5) %>%
  spread(candidate, n, fill = 0) %>%
  ungroup() %>%
  mutate_each(funs((. + 1) / sum(. + 1)), -word) %>%
  mutate(logratio = log2(Harris / Yang)) %>%
  arrange(desc(logratio))

### oh yeaaaaahhhh
yangvharrisratio %>% 
  filter(logratio>3.2 | logratio<(-3.4)) %>% 
  filter(word!="pm") %>% 
  mutate(color = ifelse(logratio>0, "red", "blue")) %>% 
  ggplot(aes(x=reorder(word,logratio), y=logratio, fill=color)) +
  geom_bar(position="dodge", stat="identity") +
  coord_flip() +
  labs(fill = "Candidate") +
  scale_fill_discrete(name = "Candidate", labels = c("Andrew Yang", "Kamala Harris")) +
  ggtitle("Most Used Words on Twitter", subtitle="Kamala Harris vs. Andrew Yang") +
  xlab("Word") +
  ylab("Log Ratio")
