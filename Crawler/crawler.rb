# Spidr is the library used to crawl the internet
require 'spidr'

=begin
    @param url is the url to be crawled
=end

def startCrawling(base_URL)

    Spidr.site(base_URL) do |spider|
        
        spider.every_page do |page|
            #TODO: parse the url & compress & save to database
            puts ">>> #{page.url}"
        end
    end
end