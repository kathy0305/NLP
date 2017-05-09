## Cleaning data
## Tasks to accomplish:

##Tokenization - identifying appropriate tokens such as words, punctuation, and numbers. Writing a function that takes a file as input and returns a tokenized version of it.
## Profanity filtering - removing profanity and other words you do not want to predict.


##Tips, tricks, and hints:

#Sampling. To reiterate, to build models you don't need to load in and use all
##of the data. 
##Often relatively few randomly selected rows or chunks need to be included to 
##get an accurate approximation to results that would be obtained using all the data.

## source(DownloadData.R)

## this is heavely based on 
## https://www3.nd.edu/~steve/computing_with_data/19_strings_and_text/strings_and_text.html#/28
## http://statechniques.com/index.php/2017/03/13/text-mining-the-game-of-thrones-part-1-who-are-the-most-important-characters-in-game-of-thrones/

## Basic Exploratory Analysis

library(tidyverse)
library(stringr)
library(ggplot2)
library(caret)
library(tm)
library(wordcloud)
library(tidytext)
## following the hint we will only take a random sample 
## Using caret pkg wanted to partition data and only take 25%
## but the system was taking too long, so just used the sample function 
## and chose to sample 2000 records from each file
set.seed(582017)
sampleTwitter <-sample (twitter, 2000,replace = FALSE)
sampleBlogs <- sample (blogs,2000, replace = FALSE)
sampleNews <- sample(news,2000, replace = FALSE)

##look at the structure
str(sampleTwitter)

## remove emojis
sampleTwitter <- iconv(sampleTwitter, 'UTF-8', 'ASCII')

## converting to corpus
##The Corpus function is very flexible. It can read PDFs, Word docs, e.g.
## Here VectorSource told the Corpus function that each document was an entry in the vector.
Twit_corpus <- Corpus(VectorSource(sampleTwitter))
print(Twit_corpus)

inspect(Twit_corpus[1:3]) ## inspect the first 3 rows


##Next, we remove the numbers,
## punctuations, 
##and extra white spaces and 
##convert all characters to lower case.
Twit_corpus <- Twit_corpus %>% 
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace) %>%
    tm_map(tolower) 


## We now create a document term matrix object Twit_Tidy,
##which we may also use for future analysis.
Twit_Tidy<-DocumentTermMatrix(Twit_corpus)
Twit_Tidy

##We can now convert from DocumentTermMatrix to tidy text 
Twit_TidyB <- tidy(Twit_Tidy)



## remove profanity
## found a list online that contains list of words banned by google
## https://www.freewebheaders.com/full-list-of-bad-words-banned-by-google/







# https://www3.nd.edu/~steve/computing_with_data/19_strings_and_text/strings_and_text.html#/28