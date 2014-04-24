class Event < ActiveRecord::Base
    validates :name, presence: true
    validates :url, uniqueness: true
    belongs_to :location
end
