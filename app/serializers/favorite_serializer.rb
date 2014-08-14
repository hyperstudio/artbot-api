class FavoriteSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :attended
  has_one :event
end
