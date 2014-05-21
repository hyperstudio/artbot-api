require 'spec_helper'

describe Entity do
  it { should validate_presence_of(:name) }

  it 'should be taggable on genre' do
    dbpedia_entity = create(
      :dbpedia_entity,
      genre_list: 'foo, bar'
    )

    expect(dbpedia_entity.genre_list).to match_array( ['foo', 'bar'])
  end
end
