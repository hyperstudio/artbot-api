require 'spec_helper'

describe TagSource do
  it { should validate_presence_of(:name) }

  context 'tagging' do
    it { should respond_to(:owned_taggings) }
    it { should respond_to(:owned_tags) }
  end

  context '#owned_tag_names' do
    it 'returns the tag names owned by a tag source' do
      entity = create(:entity)
      tag_source = create(:tag_source)

      tag_source.tag(entity, with: 'foo, bar', on: :movements)

      expect(tag_source.owned_tag_names).to match_array ['foo','bar']
    end
  end

  it 'has a dbpedia entity finder' do
    expect(described_class.dbpedia).to be_instance_of(described_class)
  end

  it 'returns a hash when cleaned' do
    tag_source = described_class.dbpedia
    expect(described_class.dbpedia)
  end

  def sample_input

  end
end
