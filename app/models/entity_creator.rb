class EntityCreator
    
    def initialize(ner_result)
        if ner_result[:source_name] == "DBpedia"
            # Check to see if it has a sensible DBpedia URI
            if ner_result[:uri].present? and self.shares_word?(ner_result[:label], ner_result[:stanford_name])
                @entity = Entity.find_or_initialize_by(url: ner_result[:uri])
            else
                # No good DBpedia URI, so just save its name and remove any DBpedia metadata
                @entity = Entity.find_or_initialize_by(stanford_name: ner_result[:stanford_name])
                ner_result.except!(:label, :description, :refcount, :categories)
            end
        elsif ner_result[:source_name] == "OpenCalais"
            @entity = Entity.find_or_initialize_by(url: ner_result[:uri])
            # If it's a socialTag rather than entity, make it a category too.
            ner_result[:categories] = [ner_result] if ner_result[:calais_type_group] == "socialTag"
        end
        self.add_attributes_to_entity(ner_result)
    end
    
    def add_attributes_to_entity(ner_result)
        @entity.name = ner_result[:label]
        @entity.source_name = ner_result[:source_name]
        @entity.description = ner_result[:description]
        @entity.refcount = ner_result[:refcount]
        @entity.score = ner_result[:score]
        @entity.calais_entity_type = ner_result[:calais_entity_type]
        @entity.calais_type_group = ner_result[:calais_type_group]
        @entity.stanford_name = ner_result[:stanford_name]
        @entity.stanford_type = ner_result[:stanford_type]
        if ner_result[:categories].present?
            @categories = ner_result[:categories].map {|r| r.symbolize_keys}
        else
            @categories = []
        end
    end

    def shares_word?(phrase1, phrase2)
        list1 = phrase1.split.map {|i| i.downcase}
        list2 = phrase2.split.map {|i| i.downcase}
        (list1 & list2).any?
    end

    attr_reader :entity, :categories
end