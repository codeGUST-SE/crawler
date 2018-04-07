require 'optparse'
require_relative 'crawlable_pages'
require_relative 'crawler'

options = {:prod => false}
OptionParser.new do |opt|
  opt.on('-i', '--input_file INPUT_FILE', 'Input filename in ./crawlables/ [required]') { |o| options[:input_file] = o }
  opt.on('-l', '--limit LIMIT', 'Crawling limit [required]') { |o| options[:limit] = Integer(o) }
  opt.on('-u', '--url URL', 'Alternative starting URL') { |o| options[:url] = o }
  opt.on('--prod', 'Production environment, development if not set') { |o| options[:prod] = o }
end.parse!

# raise an exception if the required arguments are not set
raise OptionParser::MissingArgument if options[:input_file].nil?
raise OptionParser::MissingArgument if options[:limit].nil?

Crawler.new(
  CrawlablePages.new(options[:input_file], options[:url]).get_crawlable,
  options[:limit],
  options[:prod]
).start_crawling()
