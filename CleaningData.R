## Cleaning data
## Tasks to accomplish:

##Tokenization - identifying appropriate tokens such as words, punctuation, and numbers. Writing a function that takes a file as input and returns a tokenized version of it.
## Profanity filtering - removing profanity and other words you do not want to predict.


##Tips, tricks, and hints:

#Sampling. To reiterate, to build models you don't need to load in and use all
##of the data. 
##Often relatively few randomly selected rows or chunks need to be included to 
##get an accurate approximation to results that would be obtained using all the data.
source(DownloadData.R)

## Basic Exploratory Analysis

library(tidyverse)
library(stringr)
library(ggplot2)
library(caret)

## following the hint we will only take a random sample 
## Using caret pkg wanted to partition data and only take 25%
## but the system was taking too long
set.seed(582017)
sampleTwitter <- sample (twitter, 2000,replace = FALSE)
sampleBlogs <- sample (blogs,2000, replace = FALSE)
sampleNews <- sample(news,2000, replace = FALSE)


## remove profanity
## found a list online that contains list of words banned by google
## https://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/
profanity <- read_csv("badWords.txt")
