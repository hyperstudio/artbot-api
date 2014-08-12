class FavoriteSerializer < ActiveModel::Serializer
  attributes :id, :created_at
  has_one :event
end
