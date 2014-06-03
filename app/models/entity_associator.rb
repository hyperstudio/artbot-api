class EntityAssociator
    """
    Serves two functions: 1) adds tags to entities via a specified tags source, 2) associate entities with events
    """

    def initialize(entity, context=:genre)
        @entity = entity
        @context = context
    end

    def tag_entity(tags, tag_source=nil)
        unless tag_source.present?
            tag_source = @entity.tag_sources[0]

        tag_source.tag(
            @entity, on: @context.to_s.pluralize.to_sym,
            with: old_and_new_tags(tags).join(', ')
        )
    end

    def old_and_new_tags(new_tags)
        category_finder = CategoryFinder.new(new_tags, @context)
        @entity.genres.pluck('name') + category_finder.find
    end
end