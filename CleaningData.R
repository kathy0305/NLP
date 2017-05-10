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
## http://varianceexplained.org/r/yelp-sentiment/
## Basic Exploratory Analysis

library(tidyverse)
library(stringr)
library(ggplot2)
library(caret)
library(tm)
library(wordcloud)
library(tidytext)

## read data
twitter<- readRDS("twitter.rds")
blogs <- readRDS("blogs.rds")
news <- readRDS("news.rds")

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
sampleBlogs <- iconv(sampleBlogs, 'UTF-8', 'ASCII')
sampleNews <- iconv(sampleNews, 'UTF-8', 'ASCII')

## converting to corpus
##The Corpus function is very flexible. It can read PDFs, Word docs, e.g.
## Here VectorSource told the Corpus function that each document was an entry in the vector.
Twit_corpus <- Corpus(VectorSource(sampleTwitter))
Blog_corpus <- Corpus(VectorSource(sampleBlogs))
News_corpus <- Corpus(VectorSource(sampleNews))


inspect(Twit_corpus[1:3]) ## inspect the first 3 rows


##Next, we remove the numbers,
## punctuations, 
##and extra white spaces and 
##convert all characters to lower case.

## (note to self, maybe create a function that does all that)
## Twitter
Twit_corpus <- Twit_corpus %>% 
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace) %>%
    tm_map(tolower) 
##Blogs
Blog_corpus <- Blog_corpus %>% 
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace) %>%
    tm_map(tolower)
##News
News_corpus <- News_corpus %>% 
    tm_map(removeNumbers) %>%
    tm_map(removePunctuation) %>%
    tm_map(stripWhitespace) %>%
    tm_map(tolower)


## We now create a document term matrix object Twit_Tidy,
##which we may also use for future analysis.
Twit_Tidy<-DocumentTermMatrix(Twit_corpus)
Blog_Tidy<-DocumentTermMatrix(Blog_corpus)
News_Tidy<-DocumentTermMatrix(News_corpus)


##We can now convert from DocumentTermMatrix to tidy text 
Twit_TidyB <- tidy(Twit_Tidy)


## plot
the_plot <- Twit_TidyB%>%
    count(term, wt = count) %>%
    mutate(term = reorder(term, n)) %>%
    top_n(20) %>%  ## look at the top 20 words
    ggplot(aes(term, n)) +
    geom_bar(stat = "identity", fill = "blue", alpha = 0.4, show.legend = FALSE) +
    geom_text(aes(label = n), hjust = -0.1, color = "darkgreen", size = 2.5) +
    theme_classic() +
    xlab(NULL) + ylab("Frequency") +
    coord_flip()
the_plot


## As we can see lots of useless words like:
## the, you, and , for, that....
## these are called stop words and we need to delete them
Twit_TidyB <- Twit_TidyB %>%
    anti_join(stop_words, by = c(term = "word"))



##http://varianceexplained.org/r/yelp-sentiment/

# https://www3.nd.edu/~steve/computing_with_data/19_strings_and_text/strings_and_text.html#/28