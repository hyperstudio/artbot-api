class ScraperQuerier
    SCRAPER_BASE_URL = "http://127.0.0.1:7000"

    def initialize(path)
        @path = path
    end

    def query_scraper
        endpoint = SCRAPER_BASE_URL + "/" + @path
        JsonRequester.new.get(endpoint, {})["results"]
    end
end