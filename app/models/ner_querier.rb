class NerQuerier
    NER_BASE_URL = Rails.configuration.scraper_app_url

    def initialize(path)
        @path = path
    end

    def query_ner(payload)
        endpoint = NER_BASE_URL + "/" + @path
        post_data = {:payload => payload}
        JsonRequester.new.post(endpoint, post_data)[:results]
    end

    def default_tag_source
        TagSource.insensitive_find(@path)
    end

    def parse_ner_result(result, tag_source=nil)
        if tag_source.name == "Stanford" and result[:uri].present?
            tag_source = TagSource.find_by_name("DBpedia")
        elsif tag_source.nil?
            tag_source = default_tag_source
        end
        result[:source] = tag_source
        tag_source.clean(result)
    end

    def parsed_query(payload)
        tag_source = default_tag_source
        query_ner(payload).map {|result| parse_ner_result(result, tag_source)}.compact
    end
end