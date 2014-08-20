class Entity < ActiveRecord::Base
  validates :name, presence: true
  acts_as_taggable_on TagContext.all_names.map {|name| name.to_sym}
  has_and_belongs_to_many :events
  has_and_belongs_to_many :tag_sources

  def tags(context: nil, source: nil)
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

  def admin_tags(context=nil)
    tags(context: context, source: TagSource.admin)
  end

  def tag_list(context: nil, source: nil)
    tags(context, source).pluck('name')
  end

  def add_tags(tags, tag_source, context=nil)
    if context.nil?
      contexts = TagContext.all_names
    else
      contexts = [context]
    end
    contexts.map {|subcontext| EntityAssociator.new(self, subcontext).tag_entity(tags, tag_source)}
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
end
