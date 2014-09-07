class Event < ActiveRecord::Base
  validates :name, presence: true
  validates :url, uniqueness: true
  belongs_to :location
  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites
  has_and_belongs_to_many :entities

  delegate :name, to: :location, prefix: true

  def self.recommended_for(user)
    recommended_events = current.
      matching_tags(user.favorite_tags + user.favorite_event_tags).
      not_favorited_by(user)
    if recommended_events.empty?
      recommended_events = current
    end
    recommended_events.order(:end_date)
  end

  def self.for_year(year)
    if year.present?
      where('extract(year from end_date) = ?', year)
    else
      all
    end
  end

  def self.for_month(month)
    if month.present?
      where('extract(month from end_date) = ?', month)
    else
      all
    end
  end

  def self.for_day(day)
    if day.present?
      where('extract(day from end_date) = ?', day)
    else
      all
    end
  end

  def self.newest(count)
    order('created_at DESC').limit(count)
  end

  def self.current
    where('end_date >= now()')
  end

  def self.matching_tags(tag_ids)
    joins(entities: [taggings: [:tag]]).where('tags.id IN (?)', tag_ids).distinct
  end

  def self.not_favorited_by(user)
    where.not(id: user.favorites.pluck('event_id'))
  end

  def tags(context: nil, source: nil)
    scope = ActsAsTaggableOn::Tag.joins(:taggings).where(
      'taggings.taggable_type = ? AND taggings.taggable_id IN (?)',
      'Entity', case_insensitive_entities.pluck('id')).distinct
    if !context.nil?
      scope = scope.where('taggings.context = ?', context.to_s.pluralize)
    end
    if !source.nil?
      scope = scope.where('taggings.tagger_id = ?', source.id)
    end
    scope.distinct
  end
  
  def admin_tags
    tags(source: TagSource.admin)
  end

  def tag_list
    case_insensitive_entities.joins(taggings: [:tag]).distinct('tags.name').pluck('tags.name').join(', ')
  end

  def admin_tag_list
    case_insensitive_entities.joins(taggings: [:tag]).where(
      'taggings.tagger_id = ?', TagSource.admin.id).distinct('tags.name').pluck('tags.name').join(', ')
  end

  def related_events
    EventLinker.new(self).get_scored_results
  end

  def case_insensitive_entities
    Entity.where('lower(entities.name) IN (?)', entities.pluck('name').map{|e| e.downcase})
  end

  def case_insensitive_admin_entities
    case_insensitive_entities.joins(:taggings).where('taggings.tagger_id = ?', TagSource.admin.id)
  end

  def payload
    name + " " + description
  end

  def fetch_entities(path)
    NerQuerier.new(path).parsed_query(payload)
  end

  def get_and_process_entities(ner_path)
    fetch_entities(ner_path).each do |entity_result|
      entity = EntityCreator.new(entity_result).create

      entity.add_event(self)
      # This might be redundant but it gets case-insensitive admin matches
      case_insensitive_admin_entities.distinct.map {|admin_entity| admin_entity.add_event(self)}
    end
  end
end
