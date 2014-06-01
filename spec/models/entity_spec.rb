require 'spec_helper'

describe Entity do
  it { should validate_presence_of(:name) }

  it 'should be taggable on genre' do
    entity = create(
      :entity,
      genre_list: 'foo, bar'
    )

    expect(entity.genre_list).to match_array( ['foo', 'bar'])
  end
end
