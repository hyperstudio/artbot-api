class ScraperQuerier
    SCRAPER_BASE_URL = Rails.configuration.scraper_app_url + "/scrape"

    def initialize(path)
        @path = path
    end

    def query_scraper
        endpoint = SCRAPER_BASE_URL + "/" + @path
        JsonRequester.new.get(endpoint, {})[:results]
    end
end