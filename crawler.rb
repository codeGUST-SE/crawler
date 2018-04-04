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

  POLITENESS_POLICY_GAP = 30  # wait at least 30 seconds between each request

  def initialize(crawlable, limit)
    @crawlable = crawlable
    @max_crawls = limit
    @last_request_time = 0
    @@dataset ||= Google::Cloud::Datastore.new(project_id: "codegust")
  end

  def start_crawling()
    Spidr.site(@crawlable.url, ignore_links: @crawlable.ignored_urls) do |spider|
      cnt = 0
      spider.every_url do |url|

        raw_page = get_page(url)
        crawled_page = CrawlablePages::Crawlable.new(url=url)

        # searchs for the main components needed in crawlable object passed
        @crawlable.main_divs.each do |search_for|
          parsed_page = raw_page.search(search_for)
          crawled_page.main_divs << parsed_page.text.gsub('\n', "\n") if parsed_page.count != 0
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
        add_to_datastore(crawled_page.url.to_s, crawled_page.main_divs.join("\n"))

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

  # Requests and returns the page given the url.
  # Waits if needed to comply to the politeness policy.
  def get_page(url)
    time_passed = Time.now.to_i - @last_request_time
    if time_passed < POLITENESS_POLICY_GAP
      sleep(POLITENESS_POLICY_GAP - time_passed)
    end
    raw_page = Nokogiri::HTML(open(url))
    @last_request_time = Time.now.to_i
    raw_page
  end

  def add_to_datastore(page_url, page_html)
    entity = Google::Cloud::Datastore::Entity.new
    entity.key = Google::Cloud::Datastore::Key.new "page", page_url
    entity["page_url"] = page_url
    entity["page_html"] = page_html if page_html
    entity.exclude_from_indexes! "page_html", true
    @@dataset.save entity
  end

end
