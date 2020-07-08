# load packages 
library(readxl)
library(data.table)
library(dplyr)
library(stringr)

#### Fuzzy Matching --------------------
library(RecordLinkage)

# load lexis data
sources = read_excel("MD_list.xlsx")
setDT(sources)

sources$source_name = gsub("^(.*?),.*", "\\1", sources$Publication) #keep everything before ,
sources$source_name = gsub("^(.*?);.*", "\\1", sources$source_name) #keep everything before ;
sources$source_name = gsub("^(.*?)\\..*", "\\1", sources$source_name) #keep everything before .


# load allsides data
rating = read.csv("AllSidesBiasRatings_6.6.20.csv", strip.white=TRUE)
setDT(rating)

# set a 'section' variable
patterns = c("Opinion", "Editorial", "Blogs")
rating[ , section := ifelse(str_detect(news_source, paste(patterns, collapse = "|")) == T,  "opinion", "news")]
# then get rid of the news suffix in newspaper name (but keep other suffix for now so we don't have duplicates
# suffix = c("Opinion", "Editorial", "- Opinion", "- Editorial", "- News")
rating$rating_name = gsub(" - News", "\\1", rating$news_source)

news_rating = rating[section == "news", ]


# get all the pairs between lexis newspaper and allsies newspaper
combinations  = expand.grid(source_name = unique(sources$source_name), rating_name = news_rating$rating_name, stringsAsFactors = FALSE)

combinations$rating_name = as.character(combinations$rating_name)

# find the most similar match and the score 
matches = combinations  %>% group_by(source_name) %>% mutate(match_score = levenshteinSim(tolower(source_name), tolower(rating_name))) %>%
  summarise(match = match_score[which.max(match_score)], matched_to = rating_name[which.max(match_score)]) #%>% filter(match >= 0.7)
View(matches)
