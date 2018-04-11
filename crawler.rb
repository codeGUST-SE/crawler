# Spidr is the library used to crawl the internet
require 'google/cloud/datastore'
require 'spidr'

=begin
    @param crawlable is the Crawlable object to be crawled
    @param crawls_left the max number of pages to be crawled
=end
class Crawler

  # PROD constants
  POLITENESS_POLICY_GAP_PROD = 30
  DATASTORE_KIND_PROD = 'page'

  # DEV constants
  POLITENESS_POLICY_GAP_DEV = 0
  DATASTORE_KIND_DEV = 'page_dev'

  def initialize(crawlable, limit, is_prod)
    @crawlable = crawlable
    @crawls_left = limit
    @datastore_kind = is_prod ? DATASTORE_KIND_PROD : DATASTORE_KIND_DEV
    @politeness_policy_gap = is_prod ? POLITENESS_POLICY_GAP_PROD : POLITENESS_POLICY_GAP_DEV
    @@dataset ||= Google::Cloud::Datastore.new(project_id: 'codegust')
  end

  def start_crawling()
    Spidr.site(@crawlable.url, delay: @politeness_policy_gap,
      ignore_links: @crawlable.ignore_links,
      links: @crawlable.links) do |spider|

      spider.every_html_page do |raw_page|
        crawled_page =
          CrawlablePages::CrawledPage.new(raw_page.url.to_s, raw_page.title)

        # searchs for the main components needed in crawlable object
        parsed_page = raw_page.search(*@crawlable.main_divs)
        
        # skip this page if it does not contain the divs we need
        next if parsed_page.empty?

        crawled_page.page_html = transform_text(parsed_page.text.to_s)

        # searchs for the scoring components needed in crawlable object
        @crawlable.score_divs.each do |score_name, search_for|
          parsed_score = raw_page.search(search_for).text.to_s.gsub(/[^0-9]/, '')
          if parsed_score.length != 0
            crawled_page.page_scores += "[#{score_name}:#{transform_text(parsed_score)}]"
          end
        end

        # save to Datastore
        add_to_datastore(crawled_page)
        
        return if @crawls_left == 0
        @crawls_left -= 1

      end
    end
  end

  private

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
