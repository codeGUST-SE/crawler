# Spidr is the library used to crawl the internet
require 'google/cloud/datastore'
require 'spidr'
require 'nokogiri'
require 'open-uri'
require 'uri'

=begin
    @param crawlable is the Crawlable object to be crawled
    @param max_crawls the max number of pages to be crawled
=end
class Crawler

  # PROD constants
  POLITENESS_POLICY_GAP_PROD = 30
  DATASTORE_KIND_PROD = 'page'

  # DEV constants
  POLITENESS_POLICY_GAP_DEV = 0
  DATASTORE_KIND_DEV = 'page_dev'

  MAX_TRIES = 3               # max number of tries to retrieve a page

  def initialize(crawlable, limit, is_prod)
    @crawlable = crawlable
    @max_crawls = limit
    @last_request_time = 0
    @datastore_kind = is_prod ? DATASTORE_KIND_PROD : DATASTORE_KIND_DEV
    @politeness_policy_gap = is_prod ? POLITENESS_POLICY_GAP_PROD : POLITENESS_POLICY_GAP_DEV
    @@dataset ||= Google::Cloud::Datastore.new(project_id: 'codegust')
  end

  def start_crawling()
    Spidr.site(@crawlable.url, delay: @politeness_policy_gap,
      limit: @max_crawls, ignore_links: @crawlable.ignore_links,
      links: @crawlable.links) do |spider|

      spider.every_url do |url|

        raw_page = get_page(url)
        next if raw_page == nil

        crawled_page = CrawlablePages::CrawledPage.new(url=url.to_s)

        # searchs for the main components needed in crawlable object
        @crawlable.main_divs.each do |search_for|
          parsed_page = raw_page.xpath(search_for).text.to_s
          if parsed_page.length != 0
            crawled_page.page_html += transform_text(parsed_page) + ' '
          end
        end

        # skip this page if it does not contain the divs we need
        next if crawled_page.page_html.empty?

        # read the <title> tag the page
        crawled_page.title = raw_page.search('title').text.to_s

        # searchs for the scoring components needed in crawlable object
        @crawlable.score_divs.each do |score_name, search_for|
          parsed_score = raw_page.xpath(search_for).text.to_s.gsub(/[^0-9]/, '')
          if parsed_score.length != 0
            crawled_page.page_scores += "[#{score_name}:#{transform_text(parsed_score)}]"
          end
        end

        # save to Datastore
        add_to_datastore(crawled_page)

        puts crawled_page.url              # DEBUG
        puts crawled_page.title            # DEBUG
        puts crawled_page.page_html        # DEBUG
      end
    end
  end

  private

  # Requests and returns the page given the url.
  # Returns nil if it couldn't retrieve the page.
  def get_page(url)
    done = false
    tries = 0
    while !done and (tries < MAX_TRIES)
      begin
        tries += 1
        raw_page = Nokogiri::HTML(open(url))
        done = true
      rescue OpenURI::HTTPError => e
        if e.message =~ /429/    # 429 Too Many Requests
          sleep(@politeness_policy_gap * tries)
        else
          raw_page = nil
        end
      rescue    # TODO: handle other types of exceptions
        raw_page = nil
      end
    end
    raw_page
  end

  def transform_text(page)
    transformed_page =
      page.gsub(/[\u0080-\u00ff]/, '')  # remove non-ascii chars
          .gsub(/\s+/, ' ')             # remove multiple whitespace chars
          .strip()
    transformed_page
  end

  def add_to_datastore(crawled_page)
    entity = Google::Cloud::Datastore::Entity.new
    entity.key = Google::Cloud::Datastore::Key.new @datastore_kind, crawled_page.url
    entity['page_url'] = crawled_page.url
    entity['page_title'] = crawled_page.title
    entity['page_html'] = crawled_page.page_html
    entity['page_scores'] = crawled_page.page_scores
    entity['timestamp'] = Time.now.to_i
    entity.exclude_from_indexes! 'page_html', true
    entity.exclude_from_indexes! 'page_title', true
    entity.exclude_from_indexes! 'page_scores', true
    @@dataset.save entity
  end

end
