source(DownloadData.R)

## Basic Exploratory Analysis

library(tidyverse)
library(stringr)
library(ggplot2)

##Lets see what the data looks like
head(blogs)
head(twitter)
head(news)
##looks like a collection of phrases


## Quiz asks for length of files
length(blogs)
length(twitter)
length(news)

LengthFiles <- data_frame(blogsLength=length(blogs),twitterLength=length(twitter),newsLength=length(news))


## Longest line
## Base R
MaxLines <- data_frame(B=max(nchar(blogs)), N= max(nchar(news)), T= max(nchar(twitter)))

## Using stringr pkg
MaxLinesB <- data_frame(B=max(str_length(blogs)),N=max(str_length(news)),T=max(str_length(twitter)))


##.In the en_US twitter data set, if you divide the number of lines where
##the word "love" (all lowercase) occurs by the number of lines the word 
##"hate" (all lowercase) occurs, about what do you get?

##Base R 
love_count <- sum(grepl("love", twitter))
hate_count <- sum(grepl("hate", twitter))
love_count / hate_count

## using stringr pkg and accounting for other cases (uppercases)
love_countB <- sum(str_count(twitter,  regex("love", ignore_case = TRUE)))
hate_countB <- sum(str_count(twitter,  regex("hate", ignore_case = TRUE)))                         
love_countB / hate_countB

## It looks it found more matches using the stringr pks
## perhaps because we ignored upper lower case

## so lets try to account for upper , lower case using base r see what we get

loveWords <- c("LOVE","love","Love","LOve")
hateWords <- c("HATE","hate", "Hate", "HAte")

love_countC <- sum(grepl(paste(loveWords, collapse = "|"), twitter))
hate_countC <- sum(grepl(paste(hateWords, collapse = "|"), twitter))
## this did much better

## Lets plot the differences:
# 1. Create a data frame with the results
LoveHate <- tribble(
    ~MethodUsed,~Love, ~Hate, 
    "BaseR",love_count,hate_count,
    "BaseRAdjusted", love_countC, hate_countC,
    "stringr",love_countB,hate_countB)
LoveHate <- LoveHate %>%
    mutate(rate=Love/Hate) %>% ## add the rate of Love/Hate
    mutate(total= Love + Hate) ## add total love+hate

LoveHate <- LoveHate %>% ##tidy the date
    gather(`Love`,`Hate`, key="word", value= "results")

## 2. plot 
## display the rate (love/hate) on top of the stacked bar
ggplot( LoveHate)+
    geom_bar(aes(x= MethodUsed, y=results, fill=word), stat = "identity")+
    geom_text(aes(x=MethodUsed,total +5000, label= round(rate,2)))


## Another quiz question:
## The one tweet in the en_US twitter data set that matches the word
## "biostats" says what? 
    
##baseR
biostats <- grep("biostats", twitter)
twitter[biostats]
##[1] "i know how you feel.. i have biostats on tuesday and i have yet to study =/"

##stringr
#how many times the word "biostats" appear in twitter
sum(str_detect(twitter,"biostats")) 
# [1] 1
##extract the sentence that has the word "biostats' in it
str_subset(twitter,"biostats")
# [1] "i know how you feel.. i have biostats on tuesday and i have yet to study =/"

