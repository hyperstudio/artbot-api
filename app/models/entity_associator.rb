class EntityAssociator
    """
    Serves two functions: 1) adds tags to entities via a specified tags source, 2) associate entities with events
    """
    CALAIS_ENTITY_CUTOFFS = {
        'Person' => 0.15,
        'Technology' => 0.1,
        'Movie' => 0.1,
        'IndustryTerm' => 0.1
    }

    def initialize(entity, event=nil, context=:genre)
        @entity = entity
        @event = event
        @context = context
    end

    def valid_entity?
        # default to true
        if @entity.source_name == "OpenCalais"
            if @entity.type_group == "topics"
                # Topics are not useful
                response = false
            elsif @entity.type_group == "socialTag"
                # Let it go for now
                response = true
            elsif @entity.type_group == "entities"
                # This is more complex. Cherry pick only certain entity types and score cutoffs
                if CALAIS_ENTITY_CUTOFFS[@entity.entity_type].present? and @entity.score >= CALAIS_ENTITY_CUTOFFS[@entity.entity_type]
                    response = true
                else
                    response = false
                end
            end
        else
            response = true
        end
        !!response
    end

    def tag_entity(tags)
        category_finder = CategoryFind.ner(tags, @context)
        tag_source = TagSource.find_or_create_by(name: @entity.source_name)
        tag_list = (tag_source.name == "Admin" ? category_finder.all_as_tag_list : category_finder.find_as_tag_list)

        tag_source.tag(
            @entity, on: @context.to_s.pluralize.to_sym,
            with: tag_list
        )
    end

    def add_entity_to_event
        @event.entities += [@entity] if @event.present?
    end

    def tag_and_relate_entity(categories)
        tag_entity(categories)
        add_entity_to_event
    end
end