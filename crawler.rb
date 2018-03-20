# Spidr is the library used to crawl the internet
require 'spidr'
require 'nokogiri'
require 'open-uri'
require 'uri'

=begin
    @param crawlable is the Crawlable object to be crawled
=end

def startCrawling(crawlable)
  Spidr.site(crawlable.url, ignore_links: crawlable.ignored_urls) do |spider|
    o = 0
    spider.every_url do |url|
      link_object = CrawlableSites::Crawlable.new(url=url)
      page = Nokogiri::HTML(open(url))

      # searchs for the main components needed in crawlable object passed
      crawlable.main_divs.each do |search_for|
        parsed_page = page.search(search_for)
        link_object.main_divs << parsed_page if parsed_page.count != 0
      end

      # searchs for the scoring components needed in crawlable object passed
      crawlable.score_divs.each do |search_for|
        link_object.score_divs << page.search(search_for)
      end if link_object.main_divs.count != 0

      ######################################################################
      # TODO: should be removed! this is just for testing on personal computers
      # test the output
      puts ">>#{link_object.url}"
      puts link_object.main_divs
      puts ">>>>>"
      puts link_object.score_divs
      if o == 20
        return
      end
      o += 1
      ######################################################################
      end
    end
end
