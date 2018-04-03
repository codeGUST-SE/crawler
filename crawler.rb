# Spidr is the library used to crawl the internet
require "google/cloud/datastore"
require 'spidr'
require 'nokogiri'
require 'open-uri'
require 'uri'

=begin
    @param crawlable is the Crawlable object to be crawled
    @param max_crawls the max number of pages to be crawled
=end
class Crawler

  def initialize(crawlable, limit)
    @crawlable = crawlable
    @max_crawls = limit
    @@dataset ||= Google::Cloud::Datastore.new(project_id: "codegust")
  end

  def start_crawling()
    Spidr.site(@crawlable.url, ignore_links: @crawlable.ignored_urls) do |spider|
      cnt = 0
      spider.every_url do |url|
        crawled_page = CrawlablePages::Crawlable.new(url=url)
        raw_page = Nokogiri::HTML(open(url))

        # searchs for the main components needed in crawlable object passed
        @crawlable.main_divs.each do |search_for|
          parsed_page = raw_page.search(search_for)
          crawled_page.main_divs << parsed_page.text if parsed_page.count != 0
        end

        # searchs for the scoring components needed in crawlable object passed
        @crawlable.score_divs.each do |search_for|
          crawled_page.score_divs << raw_page.search(search_for)  #TODO .text ?
        end if crawled_page.main_divs.count != 0

        # skip this page if it does not contain the divs we need
        if crawled_page.main_divs.empty?
          next
        end

        # save to Datastore
        add_to_datastore(crawled_page.url.to_s, crawled_page.main_divs.to_s)

        # Crawler Politness
        sleep 30
         
        puts crawled_page.url         # DEBUG
        puts crawled_page.score_divs  # DEBUG
        
        # stop crawling after some number of pages
        if cnt == @max_crawls
          return
        end

        cnt += 1
      end
    end
  end

  private

  def add_to_datastore(page_url, page_html)
    entity = Google::Cloud::Datastore::Entity.new
    entity.key = Google::Cloud::Datastore::Key.new "page", page_url
    entity["page_url"] = page_url
    entity["page_html"] = page_html if page_html
    entity.exclude_from_indexes! "page_html", true
    @@dataset.save entity
  end
  
end
