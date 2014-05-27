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
    entities.includes(genres: [:taggings]).map {|entity| entity.genres}.flatten
  end

  def taggings
    self.genres.map {|genre| genre.taggings}.flatten
  end

  def related_entities
    Entity.where(id: self.taggings.map {|tagging| tagging.taggable_id}).includes(:events)
  end

  def related_events
    self.related_entities.map {|entity| entity.events.where.not(id:id).includes(entities: [:genres])}.flatten
  end

  def all_related_events
    related_events = []
    entities.find_each do |entity|
      entity.genres.where("taggings_count > ?", 1).find_each do |genre|
        related_entity_ids = genre.taggings.where("taggable_id != ?", entity.id).pluck("taggable_id")
        Entity.where(id: related_entity_ids).find_each do |related_entity|
          related_entity.events.where.not(id: id).find_each do |related_event|
            unless related_events.map {|re| re[:event].id}.include?(related_event.id)
              # puts "%s, %s and %s RELATED BECAUSE %s" % [related_event.name, entity.name, related_entity.name, genre.name]
              related_events.push({
                :event => related_event,
                :entity => entity.name,
                :related_entity => related_entity.name,
                :genre => genre})
            end
          end
        end
      end
    end
    return related_events
  end

  def select_related_events(count=4)
    self.all_related_events.shuffle.take(count)
  end

  def payload
    name + " " + description
  end

  def fetch_entities(path)
    NerQuerier.new(path).query_and_parse_results(self.payload)
  end

  def fetch_and_assign_tags(tag_source_path)
    self.fetch_entities(tag_source_path).each do |entity_result|
      entity_creator = EntityCreator.new(entity_result)
      entity = entity_creator.entity
      entity.save
      # Now process the entities and tie them to events
      EntityAssociator.new(self, entity).process(tag_source_path, entity_creator.categories) if entity_creator.categories.present?
    end
  end
end
