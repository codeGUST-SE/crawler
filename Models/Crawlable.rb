=begin
    base class for the Site that's Crawlable
=end
class Crawlable 

    # setters and getters
    attr_accessor :url,:ignored_urls,:main_divs,:score_divs

    # initializer (init)
    def initialize(url,ignored_urls,main_divs,score_divs)
        @url = url
        @ignored_urls = ignored_urls
        @main_divs = main_divs
        @score_divs = score_divs
    end
end