class CrawlablePages

  DIR = 'crawlables/'

  def initialize(filename)
    @path = DIR + filename
  end

  def get
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
    Crawlable.new(hash['url'], hash['ignored_urls'], hash['main_divs'],
      hash['score_divs'])
  end

  class Crawlable
    attr_accessor :url, :ignored_urls, :main_divs, :score_divs

    def initialize(url = '', ignored_urls = [], main_divs = [], score_divs = [])
      @url = url
      @ignored_urls = ignored_urls
      @main_divs = main_divs
      @score_divs = score_divs
    end
  end
  
end
