class EntityCreator
    """
    Takes a single hash with properties and creates an entity and all associated tags
    Current options for hash: {
        :url => (the url),
        :name => (label to search by),
        :source_name => (name of the TagSource creating it),
        :entity_type => (type of entity),
        :type_group => (used for OpenCalais, 'socialTag' or 'entities'),
        :score => (relevance or confidence score),
        :refcount => (DBpedia refcount),
        :description => (longer description),
        :stanford_name => (in the case of DBpedia, the name of the stanford entity),
        :tags => (tags for these entities)
    }
    """
    
    def initialize(ner_result, save=false, add_tags=false)
        if ner_result[:url].present?
            @entity = Entity.find_or_initialize_by(url: ner_result[:url])
        elsif ner_result[:name].present?
            @entity = Entity.find_or_initialize_by(name: ner_result[:name])
        else
            @entity = nil
        end
        self.add_attributes_to_entity(ner_result)
        @tags = ner_result[:tags].present? ? ner_result[:tags] : []

        if !!save
            @entity.save
        end
        if !!add_tags
            add_tags_to_entity
        end
    end

    def add_tags_to_entity
        @entity.add_tags(@tags)
    end

    def add_attributes_to_entity(ner_result)
        @entity.name = ner_result[:name]
        @entity.source_name = ner_result[:source_name]
        @entity.description = ner_result[:description]
        @entity.refcount = ner_result[:refcount]
        @entity.score = ner_result[:score]
        @entity.entity_type = ner_result[:entity_type]
        @entity.type_group = ner_result[:type_group]
        @entity.stanford_name = ner_result[:stanford_name]
    end

    attr_reader :entity, :tags
end