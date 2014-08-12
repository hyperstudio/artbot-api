class EventSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :name,
    :url,
    :description,
    :image,
    :dates,
    :event_type,
    :start_date,
    :end_date

  has_one :location
end
