class Location < ActiveRecord::Base
    validates :name, presence: true
    validates :url, uniqueness: true
    has_many :events
    has_many :scraper_urls

    reverse_geocoded_by :latitude, :longitude

    has_attached_file :image,
        :default_url => "http://images.artbotapp.com.s3-website-us-west-2.amazonaws.com/3b3b3b.png",
        :styles => {
          :small => "200x200>",
          :large => "600x600>"
        }
    validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

    def newest_events
        events.newest(5)
    end
end
