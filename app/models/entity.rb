class Entity < ActiveRecord::Base
  acts_as_taggable_on :genres
  has_and_belongs_to_many :events

  def add_tags(categories)
    EntityAssociator.new(self).tag_entity(categories)
  end

  def relate_to_event(event)
    EntityAssociator.new(self, event).add_entity_to_event
  end

  def matching_entities
    Entity.where("name = ?", name).where.not(id: id)
  end

  def events_with_matching_entities
    matching_entities.includes(:events).each {|entity| entity.events}.flatten.uniq
  end
end
