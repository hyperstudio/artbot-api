class Event < ActiveRecord::Base
    validates :name, presence: true
    validates :url, uniqueness: true
    belongs_to :location
    has_and_belongs_to_many :dbpedia_entities

  def self.newest(count)
    order('created_at DESC').limit(count)
  end
end
