# for cleaning Tweets from Python API pull

library(readr)
uncleaned <- read_csv("customTwitterUsersCombinedUncleaned.csv")

reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"

cleaned <- uncleaned %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>% 
  filter(!is.na(text)) %>% 
  filter(text!="")

str_replace(cleaned, "\u2014", " ")

cleaned
View(uncleaned)

no_retweets <- cleaned %>% 
  filter(tweetBinary == 1)

no_retweets <- cleaned %>% 
  filter(tweetBinary == 1)

View(no_retweets)
