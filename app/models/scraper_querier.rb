class ScraperQuerier
    SCRAPER_BASE_URL = Rails.configuration.parserbot_url + "/scrape"
    SCRAPER_API_KEY = ENV['SCRAPERBOT_API_KEY']

    def initialize(path)
        @path = path
    end

    def query_scraper
        endpoint = SCRAPER_BASE_URL + "/" + @path
        params = {:key => SCRAPER_API_KEY}
        JsonRequester.get(endpoint, params)[:results]
    end
end
