class Event < ActiveRecord::Base
  validates :name, presence: true
  validates :url, uniqueness: true
  belongs_to :location
  has_and_belongs_to_many :entities

  delegate :name, to: :location, prefix: true

  def self.newest(count)
    order('created_at DESC').limit(count)
  end

  def related_events
    related_events = []
    entities.each do |entity|
      entity.genres.includes(:taggings).where("taggings_count > 1").each do |genre|
        entity_ids = genre.taggings.where("taggable_id != ?", entity.id).pluck('taggable_id')
        Entity.where(id: entity_ids).each do |related_entity|
          related_entity.events.each do |related_event|
            related_events.push(related_event)
          end
        end
      end
    end
    return related_events[0..4]
  end
end
