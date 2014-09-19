class EntityAssociator

  def initialize(entity, source, context)
    @entity = entity
    @context = context.to_s.pluralize.to_sym
    @source = source
  end

  def tag_entity(tags)
    all_tags = filter_by_context(tags) + existing_tags
    if all_tags.present?
      @source.tag(
        @entity, on: @context,
        with: all_tags.join(', ')
      )
    end
  end

  def filter_by_context(tags)
    if @source == TagSource.admin
      # Don't pattern-match it
      tags
    else
      CategoryFinder.new(tags, @context).find
    end
  end

  def existing_tags
    @entity.all_tags(context: @context, source: @source)
  end
end
