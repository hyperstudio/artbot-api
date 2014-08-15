require 'spec_helper'

describe CategoryFinder do
  it 'finds whitelisted categories based on a context' do
    finder = described_class.new(example_categories, :genre)

    expect(finder.find).to match_array(
      wanted_categories
    )
    expect(finder.find).not_to include(
      *excluded_categories
    )
    expect(finder.find).not_to include(
      *flagged_categories
    )
  end

  def wanted_categories
    ["Cubism", "Surrealism", "Land Art"]
  end

  def excluded_categories
    ["Not me"]
  end

  def flagged_categories
    ["Article and Museum are flagged words"]
  end

  def example_categories
    wanted_categories + excluded_categories + flagged_categories
  end
end
