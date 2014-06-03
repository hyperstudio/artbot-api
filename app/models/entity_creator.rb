class EntityCreator
    """
    Takes a single hash with properties and creates an entity and all associated tags
    Current options for hash: {
        :url => (the url),
        :name => (label to search by),
        :source => (instance of the TagSource),
        :entity_type => (type of entity),
        :type_group => (used for OpenCalais, 'socialTag' or 'entities'),
        :score => (relevance or confidence score),
        :refcount => (DBpedia refcount),
        :description => (longer description),
        :stanford_name => (in the case of DBpedia, the name of the stanford entity),
        :tags => (tags for these entities)
    }
    """
    
    def initialize(ner_result, save=false, add_relations=false)
        if ner_result[:url].present?
            @entity = Entity.find_or_initialize_by(url: ner_result[:url])
        elsif ner_result[:name].present?
            @entity = Entity.find_or_initialize_by(name: ner_result[:name])
        else
            @entity = nil
        end


        unless @entity.sourced_by?("DBpedia") and ner_result[:source].name == "Zemanta"
            add_attributes_to_entity(ner_result)
        end

        @tags = ner_result[:tags].present? ? ner_result[:tags] : []

        if !!save
            @entity.save
        end
        if !!add_relations
            add_relations(ner_result[:source])
        end
    end

    def add_relations(source=nil)
        @entity.add_tags(@tags, source)
        @entity.add_source(source)
    end

    def add_attributes_to_entity(ner_result)
        @entity.name = ner_result[:name]
        @entity.description = ner_result[:description]
        @entity.refcount = ner_result[:refcount]
        @entity.score = ner_result[:score]
        @entity.entity_type = ner_result[:entity_type]
        @entity.type_group = ner_result[:type_group]
        @entity.stanford_name = ner_result[:stanford_name]
    end

    attr_reader :entity, :tags
end