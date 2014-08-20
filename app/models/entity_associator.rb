class EntityAssociator
  # Serves two functions: 1) adds tags to entities via a specified tags source,
  # 2) associate entities with events

  def initialize(entity, context)
    @entity = entity
    @context = context.to_s.pluralize.to_sym
  end

  def tag_entity(tags, tag_source)
    all_tags = old_and_new_tags(tags, tag_source).join(', ')
    if all_tags.present?
      tag_source.tag(
        @entity, on: @context,
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
    new_tags | @entity.tags(context: @context, source: tag_source)
  end
end
