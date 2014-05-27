class EntityAssociator

    def initialize(event, entity, context=:genre)
        @event = event
        @entity = entity
        @context = context
    end

    def process(source, categories)
        context_finder = CategoryFinder.new(categories, @context)
        tag_source = TagSource.find_or_create_by(name: @entity.source_name.to_s)

        tag_source.tag(
            @entity, on: @context.to_s.pluralize.to_sym,
            with: context_finder.find_as_tag_list
        )
        @event.entities += [@entity]
    end
end