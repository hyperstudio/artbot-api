class Location < ActiveRecord::Base
    validates :name, presence: true
    validates :url, uniqueness: true
    has_many :events
    has_many :scraper_urls
end
