class CategoryFinder
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
    context_patterns = PATTERNS[context]
    flag_patterns = FLAGS[context]
    categories.find_all do |category|
      context_patterns.any? do |pattern|
        # Check for flags before applying the match
        unless flag_patterns.map {|flag_pattern| category[:label].match(flag_pattern)}.any?
          category[:label].match(pattern)
        end
      end
    end
  end

  def find_as_tag_list
    find.map { |tag| tag[:label] }.join(', ')
  end

  private

  attr_reader :categories, :context
end
