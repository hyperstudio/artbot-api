ActiveAdmin.register Entity do
  permit_params :name, :description, :entity_type, event_ids: []
  remove_filter :entities_events, :entities_tag_sources

  filter :name
  filter :tag_sources, as: :check_boxes
  filter :genres, :label => 'Admin Tags', :collection => proc {TagSource.admin.owned_tags}
  filter :events, :collection => proc {Event.order('name')}

  index do
    selectable_column
    id_column
    column :name
    column :url do |entity|
      link_to entity.url, entity.url, :target => :blank
    end
    column :entity_type
    column :tag_list
    column "Events" do |entity|
      entity.events.map {
        |event| link_to event.name, admin_event_path(event.id), :target => :blank
        }.join(', ').html_safe
    end
    actions
  end

  form do |f|
    f.actions
    f.inputs 'Entities' do
      f.input :name
      f.input :url
      f.input :description
      f.input :entity_type
      f.input :tag_list
    end
    f.inputs 'Events' do
      f.input :events, as: :check_boxes
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :url do |entity|
        link_to entity.url, entity.url
      end
      row :description
      row :tag_list
      row :events do |entity|
        entity.events.map {
          |event| link_to event.name, admin_event_path(event.id), :target => :blank
          }.join(', ').html_safe
      end
    end
  end

  batch_action :add_tags_to, confirm: "Add tags (comma separated)", form: {
    name: :text,
    context: [['genres', :genres]],
  } do |ids, inputs|
    admin_source = TagSource.admin
    Entity.find(ids).each do |entity|
      genre_list = entity.tag_list.empty? ? inputs["name"] : entity.tag_list + ", " + inputs["name"]
      admin_source.tag(entity, :with => genre_list, :on => inputs["context"])
    end
    redirect_to collection_path, notice: '%d entities tagged with "%s" on context "%s"' % [ids.count, inputs["name"], inputs["context"]]
  end

  batch_action :add_event_to, confirm: "Add event to selected", form: {
    name: Event.order('name').pluck('name', 'id')
  } do |ids, inputs|
    event = Event.find(inputs['name'])
    Entity.find(ids).map {|entity| entity.add_event(event)}
    redirect_to collection_path, notice: '%d entities tagged with event "%s"' % [ids.count, event.name]
  end
end

