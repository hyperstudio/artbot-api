require 'spec_helper'

describe Entity do
  it { should validate_presence_of(:name) }

  it 'should be taggable on movement' do
    entity = create(:entity)
    entity.add_tags(['Cubism', 'Surrealism', 'Bad tag'], 
        create(:tag_source), :movements)
    expect(entity.tags.pluck('name')).to match_array(['Cubism', 'Surrealism'])
  end
end
