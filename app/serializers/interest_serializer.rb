class InterestSerializer < ActiveModel::Serializer
  attributes :id
  has_one :tag
end
