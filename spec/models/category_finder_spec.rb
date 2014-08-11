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
    [
      {
        label: "Cubism",
        uri: "http://example.com/uri2"
      },
      {
        label: "Surrealism",
        uri: "http://example.com/uri3"
      },
      {
        label: "Land art",
        uri: "http://example.com/uri2"
      }
    ]
  end

  def excluded_categories
    [
      {
        label: "Not me",
        uri: "http://example.com/uri3"
      }
    ]
  end

  def flagged_categories
    [
      {
        label: "Article and Museum are flagged words",
        uri: "http://example.com/uri4"
      }
    ]
  end

  def example_categories
    wanted_categories + excluded_categories + flagged_categories
  end
end
