class Event < ActiveRecord::Base
    validates :name, presence: true
    validates :url, uniqueness: true
    belongs_to :location
    has_and_belongs_to_many :dbpedia_entities
end
