json.extract! event, :id, :name, :url, :description, :image, :dates

json.location event.location, :id, :name, :url, :description, :latitude, :longitude, :image

json.tags event.entities.map {|entity| entity.genres.pluck('name')}.reject {|genre| genre.empty?}.join(', ')