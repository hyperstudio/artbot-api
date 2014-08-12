class Event < ActiveRecord::Base
  validates :name, presence: true
  validates :url, uniqueness: true
  belongs_to :location
  has_and_belongs_to_many :entities

  delegate :name, to: :location, prefix: true

  def self.newest(count)
    order('created_at DESC').limit(count)
  end

  def genres
    genres = []
    entities.each do |entity|
      entity.matching_entities(false).find_each do |related_entity|
        genres.push(related_entity.owner_tags_on(nil, :genres))
      end
    end
    genres.flatten
  end

  def relate_to_entity(entity)
    if entity.present? and entities.include?(entity)
      entities << entity
    end
  end

  def add_related_events(events, orig_entity, related_entity, genre, existing_list=[])
    existing_ids = existing_list.map {|re| re[:event].id} + [id]
    events.each do |related_event|
      unless existing_ids.include?(related_event.id)
        existing_list.push({
          :event => related_event,
          :entity => orig_entity.name,
          :related_entity => related_entity.name,
          :genre => genre
          })
      end
    end
    existing_list
  end

  def entity_related_events
    entities.map {|e| e.matching_entity_events}.flatten.uniq
  end

  def genre_related_events
    entities.map {|e| e.related_entity_events}.flatten.uniq
  end

  def all_related_events
    related_events = []
    entities.find_each do |entity|
      # First get all the entities with the same name so we can query across them
      entities_with_same_name = entity.matching_entities(:verified_only => false)
      people_and_admins = entity.matching_entities(:verified_only => true)

      entities_with_same_name.includes(:events, :genres).find_each do |related_entity|
        # Look first for matching entity names, and make sure they are people
        add_related_events(related_entity.events, entity, related_entity, related_entity.tag_list, related_events) if people_and_admins.include?(related_entity)
        # Now look for entities related by genre
        Entity.tagged_with(related_entity.tag_list, :any => true).includes(:events).map {|e|
          add_related_events(e.events, related_entity, e, '', related_events)}
      end
    end
    related_events
  end

  def select_related_events(count=4)
    all_related_events.shuffle.take(count)
  end

  def payload
    name + " " + description
  end

  def fetch_entities(path)
    NerQuerier.new(path).parsed_query(payload)
  end

  def get_and_process_entities(ner_path)
    fetch_entities(ner_path).each do |entity_result|
      entity = EntityCreator.new(entity_result, true, true).entity
      entity.add_event(self)
      entity.admin_relations.map {|relation| relation.add_event(self)}
    end
  end
end
