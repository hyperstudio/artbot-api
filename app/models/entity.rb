class Entity < ActiveRecord::Base
  validates :name, presence: true
  acts_as_taggable_on :genres
  has_and_belongs_to_many :events

  def add_tags(tags)
    EntityAssociator.new(self).tag_entity(tags)
  end

  def relate_to_event(event)
    events += [event] if event.present?
  end

  def matching_entities
    Entity.where("name = ?", name).where.not(id: id)
  end

  def events_with_matching_entities
    matching_entities.includes(:events).each {|entity| entity.events}.flatten.uniq
  end
end
