class Location < ActiveRecord::Base
    validates :name, presence: true
    validates :url, uniqueness: true
    has_many :events
    has_many :scraper_urls

    reverse_geocoded_by :latitude, :longitude

  def newest_events
    events.newest(5)
  end
end
