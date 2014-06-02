class CategoryFinder
  ADMIN_TAGS=TagSource.admin.owned_tags.pluck('name')
  PATTERNS={
    genre: [
      %r((.+)?arch(.+)?)i,
      %r((.+)?ism(.+)?)i,
      %r((.+)?mural(.+)?)i,
      %r((.+)?sculpt(.+)?)i,
      %r((.+)?photo(.+)?)i,
      %r((.+)?paint(.+)?)i,
      %r((.+)?design(.+)?)i,
      %r((.+)?curat(.+)?)i,
      %r((.+)?print(.+)?)i,
      %r((.+)?carv(.+)?)i,
      %r((.+)?quilt(.+)?)i,
      %r((.+)?stained\sg(.+)?)i,
      %r((.+)?jewel(.+)?)i,
      %r((.+)?callig(.+)?)i,
      %r((.+)?film(.+)?)i,
      %r((.+)?cinema(.+)?)i,
      %r(\Aart(.+)?)i,
      %r((.+)art\s(.+)?)i,
      %r((.+)\sart(.+)?)i
      ]
  }
  FLAGS={
    genre: [
      %r((.+)?article(.+)?)i,
      %r((.+)?museum(.+)?)i
    ]
  }

  def initialize(categories = [], context)
    @categories = categories
    @context = context
  end

  def find
    admin_tags = ADMIN_TAGS
    lowercase_tags = admin_tags.map {|tag| tag.downcase}
    context_patterns = PATTERNS[context]
    flag_patterns = FLAGS[context]
    categories.find_all do |category|
      # See if this is an admin-added tag-- if so, we want to let it through
      if lowercase_tags.include? category.downcase
        admin_tags[lowercase_tags.index(category.downcase)]
      else
        context_patterns.any? do |pattern|
          # Check for flags before applying the match
          unless flag_patterns.map {|flag_pattern| category.match(flag_pattern)}.any?
            category.match(pattern)
          end
        end
      end
    end
  end

  def find_as_tag_list
    find.join(', ')
  end

  private

  attr_reader :categories, :context
end
