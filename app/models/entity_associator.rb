class EntityAssociator
    CALAIS_ENTITY_CUTOFFS = {
        'Person' => 0.15,
        'Technology' => 0.1,
        'Movie' => 0.1,
        'IndustryTerm' => 0.1
    }

    def initialize(event, entity, context=:genre)
        @event = event
        @entity = entity
        @context = context
    end

    def valid_entity?
        # default to true
        if @entity.source_name == "OpenCalais"
            if @entity.calais_type_group == "topics"
                # Topics are not useful
                response = false
            elsif @entity.calais_type_group == "socialTag"
                # Let it go for now
                response = true
            elsif @entity.calais_type_group == "entities"
                # This is more complex. Cherry pick only certain entity types and score cutoffs
                if CALAIS_ENTITY_CUTOFFS[@entity.calais_entity_type].present? and @entity.score >= CALAIS_ENTITY_CUTOFFS[@entity.calais_entity_type]
                    response = true
                else
                    response = false
                end
            end
        elsif @entity.source_name == "DBpedia"
            response = true
        end
        !!response
    end

    def process(categories)
        context_finder = CategoryFinder.new(categories, @context)
        tag_source = TagSource.find_or_create_by(name: @entity.source_name.to_s)

        tag_source.tag(
            @entity, on: @context.to_s.pluralize.to_sym,
            with: context_finder.find_as_tag_list
        )
        @event.entities += [@entity]
    end
end