class ScraperQuerier
    SCRAPER_BASE_URL = "http://127.0.0.1:5000/scrape"

    def initialize(path)
        @path = path
    end

    def query_scraper
        endpoint = SCRAPER_BASE_URL + "/" + @path
        JsonRequester.new.get(endpoint, {})["results"]
    end
end