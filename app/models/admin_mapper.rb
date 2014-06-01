class AdminMapper

    def initialize(entity_name, entity_url, tags, source_name='Admin')
        new_entity = {
            :source_name => 'Admin',
            :uri => entity_url,
            :label => entity_name,
            :categories => tags
        }
        entity_creator = EntityCreator.new(new_entity)
        entity_creator.entity.save
        @entity = entity_creator.entity
        @categories = entity_creator.categories
    end

    def process
        @entity.add_tags(@categories)
        @entity.events_with_matching_entities.map {|event| @entity.relate_to_event(event)}
    end

    attr_reader :entity, :categories
end