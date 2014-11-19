class SetEventAndLocationImages < ActiveRecord::Migration

  def self.up
    Location.where.not(image_url: nil).each do |location|
        begin
          puts "Location " + location.id.to_s
          location.image = location.image_url
          location.save
        rescue
          puts "Location FAILED"
        end
    end
    Event.where.not(image_url: nil).each do |event|
        begin
          puts "Event " + event.id.to_s
          event.image = event.image_url
          event.save
        rescue
          puts "Event FAILED"
        end
    end
  end

  def self.down
  end
end
