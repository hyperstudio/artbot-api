class LocationSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :name,
    :url,
    :description,
    :image,
    :latitude,
    :longitude
end
