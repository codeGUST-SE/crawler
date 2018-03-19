# Spidr is the library used to crawl the internet
require 'spidr'
require 'nokogiri'
require 'open-uri'
require 'uri'
=begin
    @param url is the url to be crawled
=end

def startCrawling(base_URL,links_to_be_ignored = [])
    
    Spidr.site(base_URL, ignore_links: links_to_be_ignored) do |spider|
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

