class Url
    def link_stackoverflow()
        return 'https://stackoverflow.com/questions'
    end

    def ignored_stackoverflow()
        return [/questions.ask/,/user(.*)/,/.jobs(.*)/,/tags(.*)/,/help(.*)/,/tour(.*)/,/company(.*)/,/tagged(.*)/,/.tab(.*)/,/election(.*)/,/opensearch.xml/] 
    end
    def link_github()
        return 'https://github.com/'
    end

    def ignored_github()
        return [/features/,/business/,/explore/,/marketplace/,/pricing/,/dashboard/,/login(.*)/,/join(.*)/,/features(.*)/,/personal(.*)/,/about(.*)/,/contact(.*)/,/site(.*)/,/blog(.*)/,/opensearch.xml/,/fluidicon.png/,/manifest.json/] 
    end
end

class Crawlable
    url = ""
    ignored_urls = []
    main_divs = []
    score_divs = []
end

class Github::Crawlable
   
end