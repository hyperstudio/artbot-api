class LocationSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :name,
    :url,
    :description,
    :image,
    :latitude,
    :longitude,
    :address,
    :hours

  def attributes
    data = super
    data[:image] = object.image.nil? ? nil : object.image.url
    data
  end
end
