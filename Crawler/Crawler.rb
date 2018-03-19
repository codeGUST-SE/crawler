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
            page = Nokogiri::HTML(open(url))
            puts url
            puts page.search('div.repository-content')
            o += 1
            if o == 100
                return
            end
          end
    end
end

