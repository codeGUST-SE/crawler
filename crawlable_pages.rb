class CrawlablePages

  DIR = 'crawlables/'

  def initialize(filename, alt_url)
    @path = DIR + filename
    @alt_url = alt_url
  end

  def get_crawlable
    file_content = ''
    File.open(@path, 'r') do |f|
      f.each_line do |line|
        # ignore lines that start with #
        if line.start_with? '#'
          next
        end
        file_content += line
      end
    end

    hash = eval(file_content)
    if !@alt_url.nil?
      hash[:url] = @alt_url
    end

    Crawlable.new(hash[:url], hash[:ignored_urls], hash[:main_divs],
      hash[:score_divs])
  end

  class Crawlable
    attr_accessor :url, :ignored_urls, :main_divs, :score_divs

    def initialize(url = '', ignored_urls = [], main_divs = [], score_divs = {})
      @url = url
      @ignored_urls = ignored_urls
      @main_divs = main_divs
      @score_divs = score_divs
    end
  end

  class CrawledPage
    attr_accessor :url, :title, :page_html, :page_scores

    def initialize(url = '', title = '', page_html = '', page_scores = '')
      @url = url
      @title = title
      @page_html = page_html
      @page_scores = page_scores
    end
  end

end
