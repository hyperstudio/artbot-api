class EntityAssociator
    """
    Serves two functions: 1) adds tags to entities via a specified tags source, 2) associate entities with events
    """

    def initialize(entity, context=:genre)
        @entity = entity
        @context = context
    end

    def tag_entity(tags)
        category_finder = CategoryFinder.new(tags, @context)
        tag_source = TagSource.find_or_create_by(name: @entity.source_name)

        tag_source.tag(
            @entity, on: @context.to_s.pluralize.to_sym,
            with: category_finder.find_as_tag_list
        )
    end
end