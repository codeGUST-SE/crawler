# codeGUST crawler

## Description

codeGUST crawler uses spidr to crawl the following websites:

- Stack Overflow
- GitHub
- Tutorials Point
- GeeksforGeeks

## Getting started

Install the dependencies:
```
$ bundle install
```

## Decide what to crawl

Crawlables are read from input files in ./crawlables/ directory.

For example: ./crawlables/crawl_github.txt contains a hash with the following keys:
- `:url` => the starting URL to crawl
- `:ignored_url` => a list of regex for URLs that will be ignored
- `:main_divs` => a list of XPaths that will be extracted from the HTML of the crawled page
- `:score_divs` => a hash of score name to XPaths that will be extracted from the HTML of the page for various scoring reasons
Note that the lines in the beginning of the file starting with # will be ignored, and the rest will be evaluated into a hash using `eval()`

## Start crawling!

Command line arguments:
```
-i, --input_file INPUT_FILE      [REQUIRED] Input filename in ./crawlables/
-l, --limit LIMIT                [REQUIRED] Crawling limit
-u, --url URL                    Alternative starting URL
--prod                           Production environment if set, development if not set
```
For example:
```
$ ruby main.rb -i crawl_github.txt -l 10
$ ruby main.rb -i crawl_github.txt -l 5 -u https://github.com/codeGUST-SE/crawler/
$ ruby main.rb -i crawl_stackoverflow.txt -l 100 --prod 
```
