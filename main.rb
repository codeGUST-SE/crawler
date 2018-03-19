# Require the dependencies from the directory
require_relative 'Crawler/Crawler'
require_relative 'Models/Models'

=begin
    Creates the Objects of the sites that are to be crawled
=end
stackoverflow = Stackoverflow.new(url = 'https://stackoverflow.com/questions')
github = Github.new(url = 'https://github.com/')

# Starts the crawling proccess
startCrawling(toBeCrawled = stackoverflow)
