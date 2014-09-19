class Entity < ActiveRecord::Base
  validates :name, presence: true
  acts_as_taggable_on TagContext.all_names.map {|name| name.to_sym}
  has_and_belongs_to_many :events
  has_and_belongs_to_many :tag_sources

  ransacker :by_tag_name, :formatter => proc {|v|
    joins(taggings: [:tag]).where('tags.name ILIKE ?', '%'+v.to_s.downcase+'%').distinct('tags.id').pluck('entities.id')
  } do |parent|
    puts parent.table[:id]
    parent.table[:id]
  end

  def all_tags(context: nil, source: nil)
    scope = ActsAsTaggableOn::Tag.joins(:taggings).where(
      'taggings.taggable_id = ? AND taggings.taggable_type = ?', self.id, self.class.name)
    unless context.nil?
      scope = scope.where('taggings.context = ?', context.to_s.pluralize)
    end
    unless source.nil?
      scope = scope.where('taggings.tagger_id = ?', source.id)
    end
    scope.distinct
  end

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
  
  def tag_list(context: nil, source: nil)
    all_tags(context: context, source: source).pluck('name')
  end

  def admin_tags(context=nil)
    all_tags(context: context, source: TagSource.admin)
  end

  def add_tags(tags, tag_source, context=nil)
    if context.nil?
      contexts = TagContext.all_names
    elsif context.respond_to?(:to_ary)
      contexts = context
    else
      contexts = [context]
    end
    contexts.map {|subcontext| EntityAssociator.new(self, tag_source, subcontext).tag_entity(tags)}
  end

  def add_event(event=nil)
    if event.present? and !events.include?(event)
      events << event
    end
  end

  def add_source(source=nil)
    if source.instance_of? String
      source = TagSource.find_by_name(source)
    end
    tag_sources << source if source.present?
  end

  attr_reader :tags
end
