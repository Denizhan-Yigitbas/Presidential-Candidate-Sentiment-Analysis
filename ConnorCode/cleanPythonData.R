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
library(cleanNLP)
library(textclean)
library(ggrepel)
library(topicmodels)
library(tm)
library(stm)
library(quanteda)

#for testing, use "sampleSet.csv"
#uncleaned <- read_csv("customTwitterUsersCombinedUncleaned.csv")
uncleaned <- read_csv("customTwitterUsersCombinedUncleaned.csv")
july1 <- read_csv("~/Desktop/R/Presidential-Candidate-Sentiment-Analysis/DenizhanCode/twitterUsersRaw.csv")
july1 <- july1 %>% 
  select(-polarity)

uncleaned <- rbind(uncleaned, july1)
uncleaned <- uncleaned %>% 
  distinct(id, .keep_all = TRUE)

reg <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"

cleaned <- uncleaned %>%
  filter(!str_detect(text, '^"')) %>%
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", "")) %>% 
  mutate(text = str_replace_all(text, "@[A-Za-z0-9_]+[A-Za-z0-9-_]+", "")) %>% 
  mutate(text = str_replace_all(text, "@", "")) %>% 
  mutate(text = str_replace_all(text, "—", " ")) %>% 
  mutate(text = str_replace_all(text, "http\\S+", "")) %>% 
  filter(!is.na(text)) %>% 
  filter(text!="")

cleaned$candidate <- recode(cleaned$candidate, "amyklobuchar"="Amy Klobuchar")
cleaned$candidate <- recode(cleaned$candidate, "ewarren"="Elizabeth Warren")
cleaned$candidate <- recode(cleaned$candidate, "BetoORourke"="Beto O'Rourke")
cleaned$candidate <- recode(cleaned$candidate, "JoeBiden"="Joe Biden")
cleaned$candidate <- recode(cleaned$candidate, "JulianCastro"="Julian Castro")
cleaned$candidate <- recode(cleaned$candidate, "TulsiGabbard"="Tulsi Gabbard")
cleaned$candidate <- recode(cleaned$candidate, "PeteButtigieg"="Pete Buttigieg")
cleaned$candidate <- recode(cleaned$candidate, "KamalaHarris"="Kamala Harris")
cleaned$candidate <- recode(cleaned$candidate, "BernieSanders"="Bernie Sanders")
cleaned$candidate <- recode(cleaned$candidate, "CoryBooker"="Cory Booker")
cleaned$candidate <- recode(cleaned$candidate, "AndrewYang"="Andrew Yang")
cleaned$candidate <- recode(cleaned$candidate, "SenGillibrand"="Kirsten Gillibrand")

cleanedtweets <- cleaned %>% 
  filter(tweetBinary == 1)

cleanedretweets <- cleaned %>% 
  filter(tweetBinary == 0)

# add polling data
polling <- data.frame(candidate = c("Joe Biden", "Bernie Sanders", "Elizabeth Warren", "Kamala Harris", "Pete Buttigieg", "Beto O'Rourke", "Cory Booker", "Amy Klobuchar", "Tulsi Gabbard", "Julian Castro", "Andrew Yang", "Kirsten Gillibrand"), 
                      polling = as.numeric(c(41.4, 14.6, 8.0, 7.0, 6.6,4.4,2.6,1.4,0.8,0.8,0.8,0.6)))

cleanedtweets <- merge(cleanedtweets, polling,by="candidate")

# subsets
amyklobuchar <- subset(cleanedtweets, candidate=="Amy Klobuchar")
andrewyang <- subset(cleanedtweets, candidate=="Andrew Yang")
berniesanders <- subset(cleanedtweets, candidate=="Bernie Sanders")
betoorourke <- subset(cleanedtweets, candidate=="Beto O'Rourke")
corybooker <- subset(cleanedtweets, candidate=="Cory Booker")
elizabethwarren <- subset(cleanedtweets, candidate=="Elizabeth Warren")
joebiden <- subset(cleanedtweets, candidate=="Joe Biden")
juliancastro <- subset(cleanedtweets, candidate=="Julian Castro")
kamalaharris <- subset(cleanedtweets, candidate=="Kamala Harris")
kirstengillibrand <- subset(cleanedtweets, candidate=="Kirsten Gillibrand")
petebuttigieg <- subset(cleanedtweets, candidate=="Pete Buttigieg")
tulsigabbard <- subset(cleanedtweets, candidate=="Tulsi Gabbard")