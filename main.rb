require_relative 'crawlable_pages'
require_relative 'crawler'

Crawler.new(CrawlablePages::GITHUB).start_crawling()
