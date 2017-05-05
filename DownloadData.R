## Download the file

fileURL <- 'https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip'
fileName <- '../NPL/Coursera-SwiftKey.zip'

## If the file is not in the directory, download it and unzip it
if(!file.exists(fileName)){
    download.file(fileURL, destfile = fileName)
    unzip(fileName, exdir = '../NPL', overwrite = T)
}

## else simply unzip it
unzip(fileName)


list.files()
## file called "final" (the unzipped folder)
list.files("final")
##that included 4 different files
## [1] "de_DE" "en_US" "fi_FI" "ru_RU"


## only interested in the en_US
list.files("final/en_US")
##[1] "en_US.blogs.txt"   "en_US.news.txt"    "en_US.twitter.txt"


## it was recommended in course to use the readLines function
## Read the data
## use UTF-8 
## Unicode. It assigns every character a unique number called a code point. 
## to read non-Latin characters
blogs <- readLines("final/en_US/en_US.blogs.txt", encoding="UTF-8")
twitter <- readLines("final/en_US/en_US.twitter.txt", encoding="UTF-8")
news <- readLines("final/en_US/en_US.blogs.txt", encoding = "UTF-8")






