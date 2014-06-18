json.extract! event, :id, :name, :url, :description, :image, :start_date, :end_date, :event_type

json.location event.location, :id, :name, :url, :description, :latitude, :longitude, :image

json.tags event.entities.map {|entity| entity.genres.pluck('name')}.reject {|genre| genre.empty?}.join(', ')