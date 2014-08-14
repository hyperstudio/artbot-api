ActiveAdmin.register Event do
  remove_filter :events_entities
  permit_params :name, :url, :image, :start_date, :end_date, :event_type

  filter :location
  filter :name
  filter :entities, :collection => proc {Entity.order('name')}
  filter :event_type, as: :select
  filter :start_date
  filter :end_date

  index do
    selectable_column
    id_column
    column :name
    column :url
    column :event_type
    column :location
    column :start_date
    column :end_date
    column "Entities" do |event|
      event.entities.pluck('name').join(', ')
    end
    # column "Tags" do |event|
    #   event.entities.map {|entity| entity.genres.pluck('name')}.reject {|genre| genre.empty?}.join(', ')
    # end
    actions
  end
end
