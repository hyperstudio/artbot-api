class CategoryFinder
  PATTERNS = {
    genre: [
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
    ]
  }

  FLAGS = {
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
    admin_tags = TagSource.admin.owned_tag_names
    lowercase_admin_tags = admin_tags.map {|tag| tag.downcase}
    categories.find_all do |category|
      # See if this is an admin-added tag-- if so, we want to let it through
      label = category[:label]
      if lowercase_admin_tags.include? label.downcase
        true
      else
        context_patterns.any? do |pattern|
          if no_flagged_term_matches_on(label)
            label.match(pattern)
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
