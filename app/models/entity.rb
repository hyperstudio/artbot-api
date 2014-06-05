class Entity < ActiveRecord::Base
  validates :name, presence: true
  acts_as_taggable_on :genres
  has_and_belongs_to_many :events
  has_and_belongs_to_many :tag_sources

  def add_tags(tags, source=nil)
    EntityAssociator.new(self).tag_entity(tags, source)
  end

  def admin_relations
    matching_entities(:verified_only => false).includes(:tag_sources).map {|e| e.sourced_by?('Admin') ? e : nil}.compact
  end

  def add_event(event=nil)
    if event.present? and !events.include?(event)
      events << event
    end
  end

  def matching_entities(verified_only: true, case_sensitive: false, omit_self: false)
    if !!case_sensitive
      query = Entity.where("entities.name = ?", name)
    else
      query = Entity.where("lower(entities.name) = ?", name.downcase)
    end

    if !!omit_self
      query = query.where.not(id: id)
    end

    if !!verified_only and entity_type != "person" and !sourced_by?('Admin')
      query = query.joins(:tag_sources).where('entity_type = ? OR tag_sources.name = ?', "person", "Admin")
    end
    query
  end

  def matching_entity_events
    matching_entities.includes(:events).where.not(events: {id: events.pluck('id')}).map {|e| e.events}.flatten.uniq
  end

  def related_entities
    related_entities = []
    matching_entities(:verified_only => false).includes(:genres).find_each do |entity|
      related_entities.push(Entity.tagged_with(entity.tag_list, :any => true))
    end
    related_entities.flatten.uniq
  end

  def related_entity_events
    related_events = []
    matching_entities(:verified_only => false).includes(:genres).find_each do |entity|
      related_events.push(Entity.tagged_with(entity.tag_list, :any => true).includes(:events).map {|e| e.events}.flatten)
    end
    related_events.flatten.uniq.select {|e| !events.include?(e)}
  end

  def tag_list
    genres.pluck('name').join(', ')
  end

  def source_list
    tag_sources.pluck('name').join(', ')
  end

  def event_list
    events.pluck('name').join(', ')
  end

  def tags_sourced_by(tag_source)
    if tag_source.instance_of? String
      tag_source = TagSource.find_by_name(tag_source)
    end
    tag_source.owned_taggings.where(taggable_id: id, taggable_type: "Entity").includes(:tag).map {|t| t.tag.name}
  end

  def sourced_by?(source_name)
    tag_sources.pluck('name').include?(source_name)
  end

  def add_source(source=nil)
    if source.instance_of? String
      source = TagSource.find_by_name(source)
    end
    tag_sources << source if source.present?
  end
end
