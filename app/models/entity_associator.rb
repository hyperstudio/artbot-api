class EntityAssociator

    def initialize(event, entity, context=:genre)
        @event = event
        @entity = entity
        @context = context
    end

    def process_dbpedia(categories)
        dbpedia_tag_source = TagSource.dbpedia
        context_finder = CategoryFinder.new(categories, @context)

        dbpedia_tag_source.tag(
            @entity, on: @context.to_s.pluralize.to_sym,
            with: context_finder.find_as_tag_list
        )
        @event.entities += [@entity]
    end
end