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
  end

  it 'emits a comma-separated list of tags' do
    finder = described_class.new(example_categories, :genre)

    expect(finder.find_as_tag_list).to eq 'Cubism, Surrealism'
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

  def example_categories
    wanted_categories + excluded_categories
  end
end
