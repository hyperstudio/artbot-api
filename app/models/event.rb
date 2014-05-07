class Event < ActiveRecord::Base
  validates :name, presence: true
  validates :url, uniqueness: true
  belongs_to :location
  has_and_belongs_to_many :dbpedia_entities

  delegate :name, to: :location, prefix: true

  def self.newest(count)
    order('created_at DESC').limit(count)
  end

  def related_events
    Event.where('id != ?', id).newest(5)
  end
end
