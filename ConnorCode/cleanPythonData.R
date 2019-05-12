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
uncleaned <- read_csv("customTwitterUsersCombinedUncleaned.csv")

reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"

cleaned <- uncleaned %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>% 
  filter(!is.na(text)) %>% 
  filter(text!="") %>% 
  mutate(text = str_replace_all(text, "@[A-Za-z0-9_]+[A-Za-z0-9-_]+", "")) %>% 
  mutate(text = str_replace_all(text, "@", "")) %>% 
  mutate(text = str_replace_all(text, "—", " ")) %>% 
  mutate(text = str_replace_all(text, "http\\S+", ""))

tweets <- cleaned %>% 
  filter(tweetBinary == 1)

retweets <- cleaned %>% 
  filter(tweetBinary == 0)

tweets$candidate <- recode(tweets$candidate, "amyklobuchar"="Amy Klobuchar")
tweets$candidate <- recode(tweets$candidate, "ewarren"="Elizabeth Warren")
tweets$candidate <- recode(tweets$candidate, "BetoORourke"="Beto O'Rourke")
tweets$candidate <- recode(tweets$candidate, "JoeBiden"="Joe Biden")
tweets$candidate <- recode(tweets$candidate, "JulianCastro"="Julian Castro")
tweets$candidate <- recode(tweets$candidate, "TulsiGabbard"="Tulsi Gabbard")
tweets$candidate <- recode(tweets$candidate, "PeteButtigieg"="Pete Buttigieg")
tweets$candidate <- recode(tweets$candidate, "KamalaHarris"="Kamala Harris")
tweets$candidate <- recode(tweets$candidate, "BernieSanders"="Bernie Sanders")
tweets$candidate <- recode(tweets$candidate, "CoryBooker"="Cory Booker")
tweets$candidate <- recode(tweets$candidate, "AndrewYang"="Andrew Yang")
tweets$candidate <- recode(tweets$candidate, "SenGillibrand"="Kirsten Gillibrand")

# add polling data
polling <- data.frame(candidate = c("Joe Biden", "Bernie Sanders", "Elizabeth Warren", "Kamala Harris", "Pete Buttigieg", "Beto O'Rourke", "Cory Booker", "Amy Klobuchar", "Tulsi Gabbard", "Julian Castro", "Andrew Yang", "Kirsten Gillibrand"), 
                      polling = as.numeric(c(41.4, 14.6, 8.0, 7.0, 6.6,4.4,2.6,1.4,0.8,0.8,0.8,0.6)))

tweets <- merge(tweets, polling,by="candidate")

# subsets
amyklobuchar <- subset(tweets, candidate=="Amy Klobuchar")
andrewyang <- subset(tweets, candidate=="Andrew Yang")
berniesanders <- subset(tweets, candidate=="Bernie Sanders")
betoorourke <- subset(tweets, candidate=="Beto O'Rourke")
corybooker <- subset(tweets, candidate=="Cory Booker")
elizabethwarren <- subset(tweets, candidate=="Elizabeth Warren")
joebiden <- subset(tweets, candidate=="Joe Biden")
juliancastro <- subset(tweets, candidate=="Julian Castro")
kamalaharris <- subset(tweets, candidate=="Kamala Harris")
kirstengillibrand <- subset(tweets, candidate=="Kirsten Gillibrand")
petebuttigieg <- subset(tweets, candidate=="Pete Buttigieg")
tulsigabbard <- subset(tweets, candidate=="Tulsi Gabbard")