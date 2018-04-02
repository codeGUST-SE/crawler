# codeGUST crawler

## Description

codeGUST crawler uses spidr to crawl the following websites:

- Stack Overflow
- GitHub

## Getting started

Install the dependencies:
```
$ bundle install
```

## Decide what to crawl

Crawlables are read from input files in ./crawlables/ directory. 

For example: ./crawlables/crawl_github.txt contains a hash with the following keys:
- 'url' => the starting URL to crawl
- 'ignored_url' => a list of regex for URLs that will be ignored 
- 'main_divs' => a list of <div> IDs that will be extracted from the HTML of the crawled page
- 'score_divs' => a list of <div> IDs that will be extracted from the HTML of the page for various scoring reasons
Note that the lines in the beginning of the file starting with # will be ignored, and the rest will be evaluated into a hash using `eval()`

## Start crawling!

Two command line arguments are required: 
- filename: specifies which crawlable from ./crawlables/ directory we want to start crawling
- limit: the maximum number of crawls before the crawler stops

For example:
```
$ ruby main.rb crawl_github.txt 10
```
