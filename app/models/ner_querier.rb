class NerQuerier
    NER_BASE_URL = Rails.configuration.scraper_app_url
    SOURCE_HASH = {
        :calais => TagSource.calais,
        :stanford => TagSource.stanford,
        :dbpedia => TagSource.dbpedia
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
            source_key = (result[:uri].nil? ? :stanford : @path.to_sym)
            tag_source = SOURCE_HASH[source_key]
        result[:source_name] = tag_source.name
        if tag_source.name == 'OpenCalais'
            result[:label] = result.delete :name
            result[:uri] = result.delete :calais_id
        elsif tag_source.name == 'Stanford'
            result[:label] = result.delete :stanford_name
            result[:entity_type] = result.delete :stanford_type
        elsif tag_source.name == 'DBpedia'
            result[:entity_type] = result.delete :stanford_type
        end
        return result
    end

    def parsed_query(payload)
        query_ner(payload).map {|result| parse_ner_result(result)}
    end
end