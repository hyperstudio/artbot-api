class ScraperUrl < ActiveRecord::Base
    belongs_to :location

    def query_scraper_app
        ScraperQuerier.new(name).query_scraper
    end
end
