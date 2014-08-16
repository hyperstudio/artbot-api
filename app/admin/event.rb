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
    column :url do |event|
      link_to event.url, event.url, :target => :blank
    end
    column :event_type
    column :location do |event|
      link_to event.location.name, admin_event_path(event.location.id), :target => :blank
    end
    column :start_date
    column :end_date
    column "Entities" do |event|
      event.entities.map {
        |entity| link_to entity.name, admin_entity_path(entity.id), :target => :blank
      }.join(', ').html_safe
    end
    actions
  end

  form do |f|
    f.actions
    f.inputs 'Events' do |event|
      f.input :name
      f.input :url
      f.input :location
      f.input :event_type
      f.input :start_date
      f.input :end_date
      f.input :description
      f.input :image
    end
    f.inputs 'Tags' do |event|
      f.input :entities
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :url do |event|
        link_to event.url, admin_event_path(event.id), :target => :blank
      end
      row :location
      row :event_type
      row :start_date
      row :end_date
      row :description
      row :image do |event|
        link_to event.image, event.image, :target => :blank
      end
    end
  end
end
