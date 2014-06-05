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
        end

        all_tags = old_and_new_tags(tags, tag_source).join(', ')
        if all_tags.present?
            tag_source.tag(
                @entity, on: @context.to_s.pluralize.to_sym,
                with: all_tags
            )
        end
    end

    def old_and_new_tags(new_tags, tag_source)
        unless tag_source == TagSource.admin
            # Make sure these are legit names
            category_finder = CategoryFinder.new(new_tags, @context)
            new_tags = category_finder.find
        end
        new_tags | @entity.tags_sourced_by(tag_source)
    end
end