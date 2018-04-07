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
  MAX_TRIES = 3               # max number of tries to retrieve a page

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
        next if raw_page == nil

        crawled_page = CrawlablePages::CrawledPage.new(url=url.to_s)

        # searchs for the main components needed in crawlable object passed
        @crawlable.main_divs.each do |search_for|
          parsed_page = raw_page.search(search_for)
          if parsed_page.count != 0
            crawled_page.page_html += transform_text(parsed_page.text.to_s) + ' '
          end
        end

        # skip this page if it does not contain the divs we need
        next if crawled_page.page_html.empty?

        # read the <title> tag the page
        crawled_page.title = raw_page.search('title').text.to_s

        # searchs for the scoring components needed in crawlable object passed
        @crawlable.score_divs.each do |score_name, search_for|
          parsed_score = raw_page.search(search_for)
          if parsed_score.count != 0
            crawled_page.page_scores += "#{:score_name}:#{parsed_score.text.to_s}"
          end
        end

        # save to Datastore
        add_to_datastore(crawled_page)

        puts crawled_page.url         # DEBUG
        puts crawled_page.title       # DEBUG
        # puts crawled_page.page_scores   # DEBUG

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
  # Returns nil if it couldn't retrieve the page.
  def get_page(url)
    time_passed = Time.now.to_i - @last_request_time
    if time_passed < POLITENESS_POLICY_GAP
      sleep(POLITENESS_POLICY_GAP - time_passed)
    end

    done = false
    tries = 0
    while !done and tries < MAX_TRIES
      begin
        tries += 1
        raw_page = Nokogiri::HTML(open(url))
        done = true
      rescue OpenURI::HTTPError # 429 Too Many Requests
        sleep(POLITENESS_POLICY_GAP * tries)
      rescue                    # TODO: handle other types of exceptions
        raw_page = nil
      end
    end

    @last_request_time = Time.now.to_i
    raw_page
  end

  def transform_text(page)
    transformed_page = page.gsub(/\s+/, ' ').strip()
    transformed_page
  end

  def add_to_datastore(crawled_page)
    entity = Google::Cloud::Datastore::Entity.new
    entity.key = Google::Cloud::Datastore::Key.new "page", crawled_page.url
    entity["page_url"] = crawled_page.url
    entity["page_title"] = crawled_page.title
    entity["page_html"] = crawled_page.page_html
    entity.exclude_from_indexes! "page_html", true
    entity.exclude_from_indexes! "page_title", true
    @@dataset.save entity
  end

end
