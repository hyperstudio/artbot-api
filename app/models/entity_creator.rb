class EntityCreator

#   Takes a single hash with properties and creates an entity and all associated tags
#   Current options for hash: {
#       :url => (the url),
#       :name => (label to search by),
#       :source => (instance of the TagSource),
#       :entity_type => (type of entity),
#       :type_group => (used for OpenCalais, 'socialTag' or 'entities'),
#       :score => (relevance or confidence score),
#       :refcount => (DBpedia refcount),
#       :description => (longer description),
#       :stanford_name => (in the case of DBpedia, the name of the stanford entity),
#       :tags => (tags for these entities)
#   }

    def initialize(ner_result)
        if ner_result[:url].present?
            @entity = Entity.find_or_initialize_by(url: ner_result[:url])
        elsif ner_result[:name].present?
            @entity = Entity.find_or_initialize_by(name: ner_result[:name])
        else
            @entity = nil
        end

        if ner_result[:url].present? and ner_result[:url].include?("dbpedia.org") and @entity.taggings.pluck('tagger_id').include?(TagSource.dbpedia.id)
            # Make sure we aren't overriding the original dbpedia version.
            if ner_result[:source].name == "Admin"
                # Only add the new entity type, keep all else as-is
                @entity.entity_type = ner_result[:entity_type]
            elsif ner_result[:source].name == "Zemanta"
                # Don't override anything
            end
        else
            add_attributes_to_entity(ner_result)
        end

        @tags = ner_result[:tags].present? ? ner_result[:tags] : []
        @source = ner_result[:source]
    end

    def add_attributes_to_entity(ner_result)
        @entity.name = ner_result[:name]
        @entity.description = ner_result[:description]
        @entity.refcount = ner_result[:refCount]
        @entity.score = ner_result[:score]
        @entity.stanford_name = ner_result[:stanford_name]
        if ner_result[:entity_type].present?
            @entity.entity_type = ner_result[:entity_type]
        end
    end

    def add_relations
        @entity.add_tags(@tags, @source)
        @entity.add_source(@source)
    end

    def create
        @entity.save
        add_relations
        @entity
    end

    attr_reader :entity, :tags
end
