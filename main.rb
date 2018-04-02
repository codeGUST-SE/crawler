require_relative 'crawlable_pages'
require_relative 'crawler'

if !ARGV.length.between?(2, 3)
  raise ArgumentError, "Invalid number of arguments"
end

filename = ARGV[0]
limit = Integer(ARGV[1])

if ARGV.length == 3
  url = ARGV[2]
end

Crawler.new(CrawlablePages.new(filename, url).get_crawlable, limit).start_crawling()
