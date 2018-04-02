require_relative 'crawlable_sites'
require_relative 'crawler'

Crawler.new(CrawlableSites::GITHUB).start_crawling()
