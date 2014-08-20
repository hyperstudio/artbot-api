require 'spec_helper'

describe EntityAssociator do

    it 'filters tags by context' do
        entity = create(:entity)
        source = create(:tag_source)
        tags = ['Cubism', 'surrealism']

        described_class.new(entity, source, :movements).tag_entity(tags)
        described_class.new(entity, source, :eras).tag_entity(tags)

        expect(entity.tag_list).to eq tags
        expect(entity.tag_list(context: :movements)).to eq tags
        expect(entity.tag_list(context: :eras)).to eq []
    end

    it 'tags all admin sources' do
        entity = create(:entity)
        source = create(:admin_source)
        tags = ['foo', 'bar', 'Not matching any pattern']

        described_class.new(entity, source, :movements).tag_entity(tags)

        expect(entity.tag_list).to eq tags
    end

    it 'keeps existing tags' do
        entity = create(:entity)
        source = create(:tag_source)
        orig_tags = ['Cubism', 'Surrealism']
        new_tags = ['Dadaism']

        described_class.new(entity, source, :movements).tag_entity(orig_tags)
        expect(entity.tag_list).to eq orig_tags

        described_class.new(entity, source, :movements).tag_entity(new_tags)
        expect(entity.tag_list).to eq orig_tags + new_tags
    end
end