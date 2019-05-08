### STEP ONE: CLEAN DATA FROM PYTHON API PULL, MAKE SUBSETS

rm(list=ls())
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

#in actual,"customTwitterUsersCombinedUncleaned.csv" not "sampleSet"
uncleaned <- read_csv("sampleSet.csv")

reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"

cleaned <- uncleaned %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>% 
  filter(!is.na(text)) %>% 
  filter(text!="") 

cleaned$text <- str_replace(cleaned$text, "—", " ")

tweets <- cleaned %>% 
  filter(tweetBinary == 1)

retweets <- cleaned %>% 
  filter(tweetBinary == 0)

tweets_mention_trump <- tweets %>% 
  filter(str_detect(tweets$text, "Trump")==TRUE)

tweets$candidate <- recode(tweets$candidate, "amyklobuchar"="AmyKlobuchar")
tweets$candidate <- recode(tweets$candidate, "ewarren"="EWarren")
