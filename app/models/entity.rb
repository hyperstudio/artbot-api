class Entity < ActiveRecord::Base
  validates :name, presence: true
  acts_as_taggable_on :genres
  has_and_belongs_to_many :events
  has_and_belongs_to_many :tag_sources

  def add_tags(tags, source=nil)
    EntityAssociator.new(self).tag_entity(tags, source)
  end

  def add_source(source=nil)
    if source.respond_to?('to_s')
      source = TagSource.find_or_create_by(name: source)
    end
    tag_sources += [source] if source.present?
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

  def sourced_by?(source_name)
    tag_sources.pluck('name').include?(source_name)
  end
end
