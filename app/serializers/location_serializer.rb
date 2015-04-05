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
    :hours,
    :price

  def attributes
    data = super
    data[:image] = object.image.nil? ? "" : object.image.url(:large)
    data
  end
end
