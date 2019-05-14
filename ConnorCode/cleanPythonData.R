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

#in actual,"customTwitterUsersCombinedUncleaned.csv" not "sampleSet.csv"
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

cleanedtweets <- cleaned %>% 
  filter(tweetBinary == 1)

cleanedretweets <- cleaned %>% 
  filter(tweetBinary == 0)

cleanedtweets$candidate <- recode(cleanedtweets$candidate, "amyklobuchar"="Amy Klobuchar")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "ewarren"="Elizabeth Warren")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "BetoORourke"="Beto O'Rourke")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "JoeBiden"="Joe Biden")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "JulianCastro"="Julian Castro")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "TulsiGabbard"="Tulsi Gabbard")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "PeteButtigieg"="Pete Buttigieg")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "KamalaHarris"="Kamala Harris")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "BernieSanders"="Bernie Sanders")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "CoryBooker"="Cory Booker")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "AndrewYang"="Andrew Yang")
cleanedtweets$candidate <- recode(cleanedtweets$candidate, "SenGillibrand"="Kirsten Gillibrand")

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
petebuttigieg <- subset(tweets, candidate=="Pete Buttigieg")
tulsigabbard <- subset(tweets, candidate=="Tulsi Gabbard")