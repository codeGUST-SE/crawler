require_relative 'crawlable_pages'
require_relative 'crawler'

if ARGV.length != 2
  raise ArgumentError, "Invalid number of arguments"
end

filename = ARGV[0]
limit = Integer(ARGV[1])

Crawler.new(CrawlablePages.new(filename).get_crawlable, limit).start_crawling()
