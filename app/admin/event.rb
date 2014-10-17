ActiveAdmin.register Event do
  remove_filter :events_entities
  permit_params :name, :url, :image, :description, :dates, :start_date, :end_date, 
                :location_id, :event_type, entity_ids: [], version_ids: []

  config.per_page = 10

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
      link_to event.location.name, admin_location_path(event.location.id), :target => :blank
    end
    column :start_date
    column :end_date
    column "Entities" do |event|
      event.entities.map {
        |entity| link_to entity.name, admin_entity_path(entity.id), :target => :blank
      }.join(', ').html_safe
    end
    column "Tags" do |event|
      event.tag_list
    end
    column "Admin Tags" do |event|
      event.admin_tag_list
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
      f.input :dates, label: 'Date as string'
      f.input :start_date
      f.input :end_date
      f.input :description
      f.input :image
    end
    f.inputs 'Tags' do |event|
      f.input :entities, 
        :input_html => { :style => 'height:500px;'}, 
        :collection => Entity.order('name')
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
      row :dates, label: 'Date as string'
      row :start_date
      row :end_date
      row :description
      row :image do |event|
        link_to event.image, event.image, :target => :blank
      end
      row :entities do |event|
        event.entities.map {
          |entity| link_to entity.name, admin_entity_path(entity.id), :target => :blank
          }.join(', ').html_safe
      end
      row :versions do |event|
        event.versions.map {
          |version| link_to version.id, admin_version_path(version.id), :target => :blank
        }.join(', ').html_safe
      end
      row :tags do |event|
        event.tag_list
      end
      row :admin_tags do |event|
        event.admin_tag_list
      end
      row :created_at
      row :updated_at
    end
  end

  csv do
    column :id
    column :name
    column :url
    column('Location') {|event| event.location.name}
    column :description
    column :image
    column :event_type
    column :dates
    column :start_date
    column :end_date
    column('Entities') {
      |event| event.entities.map {
        |entity| entity.name
        }.join(', ')
      }
    column('Tags') {|event| event.tag_list}
    column('Admin Tags') {|event| event.admin_tag_list}
  end

  batch_action :run_ner_on do |ids|
    ALL_NER_PATHS = ['stanford', 'opencalais', 'zemanta']
    Event.find(ids).each do |event|
      ALL_NER_PATHS.map {|path| event.delay.get_and_process_entities(path)}
    end
    redirect_to collection_path, notice: '%d events processed with NER' % ids.count
  end
end
