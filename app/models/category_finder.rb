class CategoryFinder
  PATTERNS={
    genre: [
      %r(.+ism\Z)
      ]
  }

  def initialize(categories = [], context)
    @categories = categories
    @context = context
  end

  def find
    context_patterns = PATTERNS[context]
    categories.find_all do |category|
      context_patterns.any? do |pattern|
        category[:label].match(pattern)
      end
    end
  end

  def find_as_tag_list
    find.map { |tag| tag[:label] }.join(', ')
  end

  private

  attr_reader :categories, :context
end
