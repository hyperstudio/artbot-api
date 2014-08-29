class EventSerializer < ActiveModel::Serializer
  delegate :params, to: :scope
  
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

  def booleanize(val)
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean val
  end

  def attributes
    data = super
    if params.present? && booleanize(params[:related]) == true
        data[:related] = object.related_events
    end
    data
  end
end
