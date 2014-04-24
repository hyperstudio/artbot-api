class Location < ActiveRecord::Base
    validates :name, presence: true
    validates :url, uniqueness: true
    has_many :events
end
