class CategoryFinder
  PATTERNS = {
    movements: [
      %r((.+)?archit(.+)?)i,
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
    ],
    eras: [
      %r((.+)?century(.+)?)i,
    ],
    regions: [
    ],
    mediums: [
    ],
    miscellaneous: [
    ]
  }

  FLAGS = {
    movements: [
      %r((.+)?article(.+)?)i,
      %r((.+)?museum(.+)?)i
    ],
    eras: [
    ],
    regions: [
    ],
    mediums: [
    ],
    miscellaneous: [
    ]
  }

  def initialize(categories = [], context)
    @categories = categories
    @context = context
  end

  def find
    admin_tags = TagSource.admin.owned_tag_names
    lowercase_admin_tags = admin_tags.map {|tag| tag.downcase}
    categories.find_all do |category|
      # See if this is an admin-added tag-- if so, we want to let it through
      if lowercase_admin_tags.include? category.downcase
        true
      else
        context_patterns.any? do |pattern|
          if no_flagged_term_matches_on(category)
            category.match(pattern)
          end
        end
      end
    end
  end

  private

  attr_reader :categories, :context

  def context_patterns
    PATTERNS[context]
  end

  def no_flagged_term_matches_on(label)
    flagged_term_patterns.map {|flag_pattern| label.match(flag_pattern)}.none?
  end

  def flagged_term_patterns
    FLAGS[context]
  end

end
