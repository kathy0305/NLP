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
## https://rstudio-pubs-static.s3.amazonaws.com/41960_8f47f1da9e4044b1b1fcfc1895ff2c53.html
## Basic Exploratory Analysis

library(tidyverse)
library(stringr)
library(tm)
library(wordcloud)
library(tidytext)
library(Rweka)

## read data
twitter<- readRDS("twitter.rds")
blogs <- readRDS("blogs.rds")
news <- readRDS("news.rds")

## following the hint we will only take a random sample 
## Using caret pkg wanted to partition data and only take 25%
## but the system was taking too long, so just used the sample function 
## and chose to sample 2000 records from each file

set.seed(582017)
sampleTwitter <-sample (twitter, 50000,replace = FALSE)
sampleBlogs <- sample (blogs,50000, replace = FALSE)
sampleNews <- sample(news,50000, replace = FALSE)

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
##A document-term matrix is a mathematical matrix that describes the 
##frequency of terms that occur in a collection of documents
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


## lots of useless words like:
## the, you, and , for, that....
## these are called stop words and we need to delete them
Twit_TidyB <- Twit_TidyB %>%
    anti_join(stop_words, by = c(term = "word"))

## replot without stopwords

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


## Lets look at sentiment analysis to look for negative words (profanities)
AFINN <- sentiments %>%  ## comes with the tidytext pkg
    filter(lexicon == "AFINN") %>%  ## use the AFINN lexicon
    select(word, afinn_score = score)


## Join the AFFIN word with our list of words 
reviews_sentiment <- Twit_TidyB%>%
    inner_join(AFINN, by = c(term = "word")) %>%
    group_by(document,count) %>%
    summarize(sentiment = mean(afinn_score)) ## get a summary

##create a per-word summary, and see which words tend to appear in 
##positive or negative reviews. 
review_words_counted <- Twit_TidyB %>%
    count(document, term, count) %>%
    ungroup()


word_summaries <- review_words_counted %>%
    group_by(term) %>%
    summarize(document=n_distinct(document),
              reviews = n(),
              uses = sum(n)) %>%
    ungroup()

## This is not needed, but I thought I continue to follow along the online examle
## filter the top 5
word_summaries_filtered <- word_summaries %>%
    filter(reviews >= 5, document >= 1)


##combine and compare the two datasets with inner_join
words_afinn <- word_summaries_filtered %>%
    inner_join(AFINN)

## plot the score
ggplot(words_afinn, aes(afinn_score, reviews)) + 
    geom_smooth(method="lm", se=FALSE, show.legend=FALSE,color="blue") +
    geom_text(aes(label = term, size = NULL), check_overlap = TRUE, vjust=1, hjust=1) +
    geom_point() +
    scale_x_continuous(limits = c(-6,6)) +
    xlab("AFINN sentiment score") +
    ylab("Number of times used")

## More Visual Analysis
## Using WordCloud
library(wordcloud)

wordcloud(Twit_TidyB$term, min.freq=20, max.words=500,scale=c(8,.2), random.order=FALSE, rot.per=0.45, 
          colors=brewer.pal(8, "Dark2"))



## found this great function for n-grams
findNGrams <- function(dataframe, n) {
    ngram <- NGramTokenizer(dataframe, Weka_control(min = n, max = n, delimiters = " \\r\\n\\t.,;:\"()?!"))
    ngram2 <- data.frame(table(ngram))
    ngram3 <- ngram2[order(ngram2$Freq, decreasing = TRUE), ]
    colnames(ngram3) <- c("text", "frequency")
    ngram3
    }

singleToken <- findNGrams(Twit_corpus, 1)
twoGrams <- findNGrams(Twit_TidyB, 2)
threeGrams <- findNGrams(Twit_corpus, 3)
fourGrams <- findNGrams(Twit_corpus, 4)

## list of top 20 for plotting
top20.1gram <- head(singleToken, 20)
top20.2gram <- head(twoGrams, 20)
top20.3gram <- head(threeGrams, 20)
top20.4gram <- head(fourGrams, 20)

ggplot(top20.2gram, aes(text, frequency))+
    geom_bar(stat = "identity", fill = "blue", alpha = 0.4) +
    coord_flip()


