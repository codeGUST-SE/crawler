require_relative 'Crawlable'

=begin
    inherite from Crawlable
=end
class Stackoverflow < Crawlable

    # init for the Object
    def initialize(url)
      # special params for class
      ignored_urls = [/questions.ask/,/user(.*)/,/.jobs(.*)/,/tags(.*)/,/help(.*)/,/tour(.*)/,/company(.*)/,/tagged(.*)/,/.tab(.*)/,/election(.*)/,/opensearch.xml/] 
      main_divs = ['div#question-header a.question-hyperlink','div.postcell','div.answercell']        
      score_divs = ['div.vote','div.favoritecount']
      super(url,ignored_urls,main_divs,score_divs)
    end
end