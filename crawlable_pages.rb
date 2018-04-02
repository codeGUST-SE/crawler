
class CrawlablePages
  class Crawlable
    attr_accessor :url, :ignored_urls, :main_divs, :score_divs

    def initialize(url = "", ignored_urls = [], main_divs = [], score_divs = [])
      @url = url
      @ignored_urls = ignored_urls
      @main_divs = main_divs
      @score_divs = score_divs
    end
  end

  GITHUB = Crawlable.new(
    'https://github.com/',
    [/features/,/business/,/explore/,/marketplace/,/pricing/,/dashboard/,/login(.*)/,/join(.*)/,/features(.*)/,/personal(.*)/,/about(.*)/,/contact(.*)/,/site(.*)/,/blog(.*)/,/opensearch.xml/,/fluidicon.png/,/manifest.json/],
    ['div#readme','div.blob-wrapper'],
    ['a.social-count.js-social-count']
  )

  STACK_OVERFLOW = Crawlable.new(
    'https://stackoverflow.com/questions',
    [/questions.ask/,/user(.*)/,/.jobs(.*)/,/tags(.*)/,/help(.*)/,/tour(.*)/,/company(.*)/,/tagged(.*)/,/.tab(.*)/,/election(.*)/,/opensearch.xml/],
    ['div#question-header a.question-hyperlink','div.postcell','div.answercell'],
    ['div.vote','div.favoritecount']
  )
end
