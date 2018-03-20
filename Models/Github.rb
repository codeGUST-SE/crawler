require_relative 'Crawlable'

=begin
    inherite from Crawlable
=end
class Github < Crawlable

    # init for the Object
    def initialize(url)
        # special params for class
      ignored_urls = [/features/,/business/,/explore/,/marketplace/,/pricing/,/dashboard/,/login(.*)/,/join(.*)/,/features(.*)/,/personal(.*)/,/about(.*)/,/contact(.*)/,/site(.*)/,/blog(.*)/,/opensearch.xml/,/fluidicon.png/,/manifest.json/] 
      main_divs = ['div#readme','div.blob-wrapper']
      score_divs = ['a.social-count.js-social-count']
      super(url,ignored_urls,main_divs,score_divs)
    end
end