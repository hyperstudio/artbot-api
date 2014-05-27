class NerQuerier
    NER_BASE_URL = Rails.configuration.scraper_app_url
    SOURCE_HASH = {
        :calais => TagSource.calais,
        :stanford => TagSource.dbpedia
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
        unless tag_source.present?
            tag_source = SOURCE_HASH[@path.to_sym]
        end
        result.symbolize_keys!
        result[:source_name] = tag_source.name
        if tag_source.name == 'OpenCalais'
            result[:label] = result.delete :name
            result[:uri] = result.delete :calais_id
            result[:calais_entity_type] = result.delete :entity_type
            result[:calais_type_group] = result.delete :type_group
        elsif tag_source.name == 'DBpedia'
        end
        return result
    end

    def query_and_parse_results(payload)
        results = self.query_ner(payload)
        tag_source = SOURCE_HASH[@path.to_sym]
        results.map {|result| self.parse_ner_result(result, tag_source)}
    end
end