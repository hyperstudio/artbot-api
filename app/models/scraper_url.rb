class ScraperUrl < ActiveRecord::Base
    belongs_to :location

    def query_scraper_app
        puts "Querying scraper app with %s" % name
        ScraperQuerier.new(name).query_scraper
    end
end
