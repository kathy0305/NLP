## Trying pkg quanteda

## I am trying to see the different methods to ngram and read text
## see which one is faster

## this script will follow along the example from:

## https://cran.r-project.org/web/packages/quanteda/vignettes/quickstart.html

library(quanteda)

## I already downloaded and unzipped required filed for the course
## and saved them in 3 rds files :blogs, news, twitter

##Creating corpus

CorpusBlogs <- corpus(blogs)
CorpusNews <- corpus(news)
CorpusTwit <- corpus (twitter)

## summary
summary(CorpusBlogs)
summary(CorpusNews)
summary(CorpusTwit)

##To extract texts from a a corpus, we use an extractor, called texts().
## lets look at the second row
texts(CorpusBlogs)[2]
##  "We love you Mr. Brown."

## lets look at row 251 in blogs
texts(CorpusBlogs)[251]
 ## "Hibiscus aguas fresca"

## playing around with summary
sum1 <- summary(CorpusBlogs)
ggplot(data=sum1, aes(x=Sentences, y=Tokens, group=1)) + geom_line() + geom_point() +
    scale_x_discrete(labels=c(seq(1789,2012,12)), breaks=seq(1789,2012,12) ) 

## what is the longest Token in blog
sum1[which.max(sum1$Tokens),]


##lets add all the corpus togther
CombinesCorpus <- CorpusBlogs+CorpusNews+CorpusTwit
## how long to process
system.time(CombinesCorpus <- CorpusBlogs+CorpusNews+CorpusTwit)
## 27.98 sec, not bad 

object.size(CombinesCorpus)
##848314376 bytes


## Extracting Features from a Corpus

## In order to perform statistical analysis such as document scaling,
##we must extract a matrix associating values for certain features with
##each document. 
##In quanteda, we use the dfm function to produce such a matrix.
##"dfm" is short for document-feature matrix, and always refers to 
##documents in rows and "features" as columns.

##Tokenizing texts

##To simply tokenize a text, quanteda provides a powerful command called tokens(). 
##This produces an intermediate object, consisting of a list of tokens in
## the form of character vectors, where each element of the list
##corresponds to an input document.

## lets see the system time to tokenize the entire combined data

system.time(tokens(CombinesCorpus))
## user      system    elapsed 
## 1005.33   26.64     2306.64

## that took almost 40 min


## so lets redo this with just random sample

CorpusBlogs <- corpus(sample (blogs, 50000,replace = FALSE))
CorpusNews <- corpus(sample (news, 50000,replace = FALSE))
CorpusTwit <- corpus (sample (twitter, 50000,replace = FALSE))
##lets add all the corpus togther
CombinesCorpus <- CorpusBlogs+CorpusNews+CorpusTwit
## how long to process
system.time(CombinesCorpus <- CorpusBlogs+CorpusNews+CorpusTwit)
## 1.5 sec


object.size(CombinesCorpus)
##44552856
system.time(tokens(CombinesCorpus))
## user    system    elapsed 
## 21.86    0.32     45.46  

TokenCombined <- tokens (CombinesCorpus)
##tokens() is deliberately conservative, 
##meaning that it does not remove anything from the text unless
## told to do so

## Lets compare to dfm(), 
##which performs tokenization and tabulates the extracted features 
##into a matrix of documents by features.
TokenCombinedDFM <- dfm(CombinesCorpus)
system.time(dfm(CombinesCorpus))
## user  system   elapsed 
##26.52    0.22   27.58
## a bit faster


## lets remove numbers and punctations
TokenCombinedDFM <- dfm(CombinesCorpus,remove_numbers = TRUE, remove_punct = TRUE)
rm(CorpusBlogs,CorpusNews,CorpusTwit)

## 1gram
OneGram <- dfm(CombinesCorpus,  remove_punct = TRUE, remove_numbers = TRUE, remove_twitter = TRUE)
topfeatures(OneGram, 20)

##2gram
TwoGram <- dfm(CombinesCorpus, ngrams = 2, what = "fastestword",
     remove_punct = TRUE, remove_numbers = TRUE, remove_twitter = TRUE)
topfeatures(TwoGram, 20)

##3grams
ThreeGram <- dfm (CombinesCorpus,ngrams = 3,what = "fastestword",
                  remove_punct = TRUE, remove_numbers = TRUE, remove_twitter = TRUE)
topfeatures(ThreeGram, 20)
##worldcloud plot for fun

textplot_wordcloud(ThreeGram, min.freq = 300, random.order = FALSE,
                   rot.per = .25, 
                   colors = RColorBrewer::brewer.pal(8,"Dark2"))

##4gram
FourGram <- dfm (CombinesCorpus,ngrams = 4,what = "fastestword",
                  remove_punct = TRUE, remove_numbers = TRUE, remove_twitter = TRUE)
topfeatures(FourGram, 20)

## save files
save(OneGram, file='OneGram.RData')
save(TwoGram, file='TwoGrams.RData')
save(ThreeGram, file='ThreeGrams.RData')
save(FourGram, file='FourGrams.RData')
