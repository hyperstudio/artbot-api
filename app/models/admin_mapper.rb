class AdminMapper

    def initialize(entity_name, entity_url, tags, source_name='Admin')
        new_entity = {
            :source_name => 'Admin',
            :uri => entity_url,
            :label => entity_name,
            :categories => tags
        }
        @entity = EntityCreator.new(new_entity, true, true).entity
    end

    def link_to_events
        @entity.events_with_matching_entities.map {|event| @entity.relate_to_event(event)}
    end

    attr_reader :entity, :tags
end