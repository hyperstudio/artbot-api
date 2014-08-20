require 'spec_helper'

describe Entity do
  it { should validate_presence_of(:name) }
  it { should have_many(:events) }

  it 'should be taggable on movement' do
    entity = create(:entity)

    tag1 = create(:tag)
    tag2 = create(:tag)
    tagging = create(:tagging, taggable: entity, tag: tag1, context: 'movements')
    tagging = create(:tagging, taggable: entity, tag: tag2, context: 'movements')

    expect(entity.tag_list).to match_array([tag1.name, tag2.name])
    expect(entity.tag_list(context: 'movements')).to match_array([tag1.name, tag2.name])
  end

  it 'should be taggable on era' do
    entity = create(:entity)

    tag1 = create(:tag)
    tag2 = create(:tag)
    tagging = create(:tagging, taggable: entity, tag: tag1, context: 'eras')
    tagging = create(:tagging, taggable: entity, tag: tag2, context: 'eras')

    expect(entity.tag_list).to match_array([tag1.name, tag2.name])
    expect(entity.tag_list(context: 'eras')).to match_array([tag1.name, tag2.name])
  end

  it 'should be taggable with a source' do
    entity = create(:entity)

    tag = create(:tag)
    source = create(:tag_source)
    tagging = create(:tagging, taggable: entity, tagger: source, tag: tag)

    expect(entity.tag_list).to match_array([tag.name])
    expect(entity.tag_list(source: source)).to match_array([tag.name])
  end

  it 'should tag across multiple contexts' do
    entity = create(:entity)

    movement_tags = ['Cubism', 'surrealism']
    era_tags = ['19th century']
    bad_tags = ['bad do not pick me']

    movements = create(:tag_context, name: 'movements')
    eras = create(:tag_context, name: 'eras')

    entity.add_tags(movement_tags + era_tags + bad_tags, create(:tag_source))

    expect(entity.tag_list).to match_array(movement_tags + era_tags)
    expect(entity.tag_list(context: :movements)).to match_array(movement_tags)
    expect(entity.tag_list(context: :eras)).to match_array(era_tags)
  end
end
