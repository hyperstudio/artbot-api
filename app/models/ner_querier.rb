class NerQuerier
    NER_BASE_URL = Rails.configuration.scraper_app_url

    def initialize(path)
        @path = path
    end

    def query_ner(payload)
        endpoint = NER_BASE_URL + "/" + @path
        post_data = {:payload => payload}
        JsonRequester.new.post(endpoint, post_data)["results"]
    end
end