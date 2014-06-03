class NerQuerier
    NER_BASE_URL = Rails.configuration.scraper_app_url
    SOURCE_HASH = {
        :calais => TagSource.calais,
        :stanford => TagSource.stanford,
        :dbpedia => TagSource.dbpedia,
        :zemanta => TagSource.zemanta
    }

    def initialize(path)
        @path = path
    end

    def query_ner(payload)
        endpoint = NER_BASE_URL + "/" + @path
        post_data = {:payload => payload}
        JsonRequester.new.post(endpoint, post_data)["results"]
    end

    def parse_ner_result(result, tag_source=nil)
        result.symbolize_keys!
        unless tag_source.present?
            source_key = @path.to_sym
            if source_key == :stanford and result[:uri].present?
                source_key = :dbpedia
            end
            tag_source = SOURCE_HASH[source_key]
        end
        result[:source] = tag_source
        tag_source.clean(result)
    end

    def parsed_query(payload)
        query_ner(payload).map {|result| parse_ner_result(result)}.compact
    end
end