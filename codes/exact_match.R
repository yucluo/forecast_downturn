# Name: Matching Allsides Rating to LexisNexis Sources (using NY as an example)
# Author: Yuchen Luo
# Date: June 25, 2020

# load packages 
library(readxl)
library(data.table)
library(dplyr)
library(stringr)


### load the newspaper data --------------------
sources = read_excel("NY_list.xlsx")
setDT(sources)

### extract source newspaper name for EXACT MATCHING----
# keep only strings before the comma 
sources$PaperName = gsub("^(.*?),.*", "\\1", sources$Publication)

# keep only strings before (
# the texts within () are either locations or names of columnist 
sources$PaperName = gsub("^(.*?)\\(.*", "\\1", sources$PaperName)

# get rid of "The" so the two lists can match better 
# convert to lowercase 
sources$PaperName = gsub("The ", "\\1", sources$PaperName) %>% tolower()

### load the rating data ----------------------
rating = read.csv("AllSidesBiasRatings_6.6.20.csv", strip.white=TRUE)
setDT(rating)

### clean up rating newspaper name for EXACT MATCHING-----
# get rid of leading and tailing white space 
# rating$news_source = gsub("^\\s+|\\s+$", "", rating$news_source)
# also get rid of "The" so the two lists can match better 
rating$PaperName = gsub("The ", "\\1", rating$news_source)

# set a 'section' variable
patterns = c("Opinion", "Editorial", "Blogs")
rating[ , section := ifelse(str_detect(PaperName, paste(patterns, collapse = "|")) == T,  "opinion", "news")]
# then get rid of the news suffix in PaperName (but keep other suffix for now so we don't have duplicates
# suffix = c("Opinion", "Editorial", "- Opinion", "- Editorial", "- News")
rating$PaperName = gsub(" - News", "\\1", rating$PaperName)

# also keep only strings before (
# the texts within () are locations, blog, humor, and web news.
# convert to lower case
rating$PaperName = gsub("^(.*?)\\(.*", "\\1", rating$PaperName) %>% tolower()
# View(sources %>% filter(str_detect(PaperName, "New York Times")))

news_rating = rating[section == "news", ]

# get rid of white space
sources$PaperName = trimws(sources$PaperName)
news_rating$PaperName = trimws(news_rating$PaperName)

# merge by paper name EXACT MATCHING -------------
joined_df = left_join(sources, news_rating, by = "PaperName")

View(joined_df)

#see how many are not matched
prop.table(table(joined_df$bias_rating, useNA = "always"))

### manually equate paper names - new york observer, new york daily news 
rating$PaperName = plyr:: revalue(rating$PaperName, c("observer " = "new york observer"))

sources$PaperName = plyr:: revalue(sources$PaperName, c("daily news" = "new york daily news"))

news_rating = rating[section == "news", ]

joined_df_1 = left_join(sources, rating, by = "PaperName")

# see how many are not matched
prop.table(table(joined_df_1$bias_rating, useNA = "always"))
