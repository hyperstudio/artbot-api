class Event < ActiveRecord::Base
  validates :name, presence: true
  validates :url, uniqueness: true
  belongs_to :location
  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites
  has_and_belongs_to_many :entities

  delegate :name, to: :location, prefix: true

  def self.recommended_for(user)
    user_favorites = user.interests.pluck('tag_id')
    event_tags = user.favorites.
      joins(event: [entities: [taggings: [:tag]]]).
      distinct('tags.id').pluck('tags.id')
    current.matching_tags(user_favorites + event_tags).
      not_favorited_by(user).order(:end_date)
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

  def tags
    ActsAsTaggableOn::Tag.joins(:taggings).where(
      'taggings.taggable_type = ? AND taggings.taggable_id IN (?)',
      'Entity', related_entities.pluck('id')).distinct
  end

  def tag_list
    related_entities.joins(taggings: [:tag]).distinct('tags.name').pluck('tags.name').join(', ')
  end

  def admin_tags
    ActsAsTaggableOn::Tag.joins(:taggings).where(
      'taggings.tagger_id = ? AND taggings.taggable_type = ? AND taggings.taggable_id IN (?)',
      5, 'Entity', related_entities.pluck('id')).distinct
  end

  def admin_tag_list
    related_entities.joins(taggings: [:tag]).where(
      'taggings.tagger_id = ?', 5).distinct('tags.name').pluck('tags.name').join(', ')
  end

  def relate_to_entity(entity)
    if entity.present? and entities.include?(entity)
      entities << entity
    end
  end

  def related_entities
    Entity.where('lower(entities.name) IN (?)', entities.pluck('name').map{|e| e.downcase})
  end

  def related_events
    EventLinker.new(self).get_scored_results
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
