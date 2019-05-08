### STEP THREE: REGRESSION AND STATISTICS STUFF
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

# do poisson regression, not sure how though lol 
# also reference http://varianceexplained.org/r/trump-tweets/
sentiment_differences <- tweets_w_sentiment %>%
  group_by(candidate) %>%
  do(tidy(poisson.test(.$candidate, .$sentiment)))

sentiment_differences
