# Spidr is the library used to crawl the internet
require "google/cloud/datastore"
require 'spidr'
require 'nokogiri'
require 'open-uri'
require 'uri'

=begin
    @param crawlable is the Crawlable object to be crawled
=end
class Crawler
  MAX_CRAWLS = 20   # TODO: Determine the max number of crawls we want

  def initialize(crawlable)
    @crawlable = crawlable
    @@dataset ||= Google::Cloud::Datastore.new(project_id: "codegust")
  end

  def start_crawling()
    Spidr.site(@crawlable.url, ignore_links: @crawlable.ignored_urls) do |spider|
      cnt = 0
      spider.every_url do |url|
        link_object = CrawlableSites::Crawlable.new(url=url)
        page = Nokogiri::HTML(open(url))

        # searchs for the main components needed in crawlable object passed
        @crawlable.main_divs.each do |search_for|
          parsed_page = page.search(search_for)
          link_object.main_divs << parsed_page if parsed_page.count != 0
        end

        # searchs for the scoring components needed in crawlable object passed
        @crawlable.score_divs.each do |search_for|
          link_object.score_divs << page.search(search_for)
        end if link_object.main_divs.count != 0

        # skip this page if it does not contain the divs we need
        if link_object.score_divs.empty?
          next
        end

        # save to Datastore
        add_to_datastore(link_object.url.to_s, link_object.main_divs.to_s)

        puts link_object.url   # DEBUG

        # stop crawling after some number of pages
        if cnt == MAX_CRAWLS
          return
        end
        
        cnt += 1
      end
    end
  end

  private

  def add_to_datastore(page_url, page_html)
    entity = Google::Cloud::Datastore::Entity.new
    entity.key = Google::Cloud::Datastore::Key.new "test", page_url
    entity["page_url"] = page_url
    entity["page_html"] = page_html if page_html
    entity.exclude_from_indexes! "page_html", true
    @@dataset.save entity
  end
end
