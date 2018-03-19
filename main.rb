# Require the crawler from the directory
require_relative 'Crawler/crawler'
require_relative 'URL'
# Starts the crawling proccess
urls = Url.new()

startCrawling(base_URL = urls.return_link_sof, links_to_be_ignored = urls.return_ignored_sof)
