# imports the models needed to map the site
require_relative '../Models/Models'
# Spidr is the library used to crawl the internet
require 'spidr'
require 'nokogiri'
require 'open-uri'
require 'uri'
=begin
    @param url is the url to be crawled
=end

def startCrawling(toBeCrawled)
    
    Spidr.site(toBeCrawled.url, ignore_links: toBeCrawled.ignored_urls) do |spider|
        o = 0
        spider.every_url do |url|
            linkObject = Crawlable.new(url=url)
            page = Nokogiri::HTML(open(url))

            # searchs for the main components needed in crawlable object passed
            toBeCrawled.main_divs.each do |search_for|
                linkObject.main_divs << page.search(search_for)
            end
            
            # searchs for the scoring components needed in crawlable object passed
        
            toBeCrawled.score_divs.each do |search_for|
                linkObject.score_divs << page.search(search_for)
            end
            
            ######################################################################
            # should be removed! this is just for testing on personal computers
            # test the output 
            puts ">>#{linkObject.url}"
            puts linkObject.score_divs
            if o == 10
                return
            end
            o += 1
            ######################################################################
          end
    end
end

