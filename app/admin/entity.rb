ActiveAdmin.register Entity do
  permit_params :name, :description, :entity_type, event_ids: []
  remove_filter :entities_events, :entities_tag_sources

  filter :name
  filter :tag_sources, as: :check_boxes
  filter :movements, :label => 'Admin Tags', :collection => proc {TagSource.admin.owned_tags}
  filter :by_tag_name_in, as: :string, label: 'Tag Name'
  filter :events, :collection => proc {Event.order('name')}

  controller do
    before_filter :load_batch_actions, :only => :index

    def load_batch_actions
      resource = active_admin_config

      resource.add_batch_action(
        :tag, 'Tag', {
          confirm: "Add tags (comma separated)",
          form: {
            name: :text, 
            context: TagContext.all_names.map {|name| [name.pluralize, name.pluralize.to_sym]}
          }
        }) do |ids, inputs|
          admin_source = TagSource.admin
          Entity.find(ids).each { |entity|
            entity.add_tags(inputs['name'].split(',').map{|n|n.strip}, admin_source, inputs['context'])
            entity.add_source(admin_source)
          }
          redirect_to collection_path, notice: '%d entities tagged with "%s" on context "%s"' % [ids.count, inputs["name"], inputs["context"]]
        end

      resource.add_batch_action(
        :add_event_to, 'Add event to', {
          confirm: "Add event",
          form: {
            name: Event.order('name').pluck('name', 'id')
          }
        }) do |ids, inputs|
          event = Event.find(inputs['name'])
          Entity.find(ids).map {|entity| entity.add_event(event)}
          redirect_to collection_path, notice: '%d entities associated with event "%s"' % [ids.count, event.name]
        end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :url do |entity|
      link_to entity.url, entity.url || '', :target => :blank
    end
    column :entity_type
    column 'Tags' do |entity|
      entity.all_tags.map {
        |tag| link_to tag, admin_tag_path(tag.id), :target => :blank
        }.join(', ').html_safe
    end
    column 'Admin Tags' do |entity|
      entity.admin_tags.map {
        |tag| link_to tag, admin_tag_path(tag.id), :target => :blank
      }.join(', ').html_safe
    end
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
      # f.input 'Admin Tags' do |entity|
      #   entity.admin_tags.map {
      #     |tag| link_to tag, admin_tag_path(tag.id), :target => :blank
      #   }.join(', ').html_safe
      # end
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
      # row :tag_list
      row :events do |entity|
        entity.events.map {
          |event| link_to event.name, admin_event_path(event.id), :target => :blank
          }.join(', ').html_safe
      end
      row 'Tags' do |entity|
        entity.all_tags.map {
          |tag| link_to tag, admin_tag_path(tag.id), :target => :blank
          }.join(', ').html_safe
      end
      row 'Admin Tags' do |entity|
        entity.admin_tags.map {
          |tag| link_to tag, admin_tag_path(tag.id), :target => :blank
        }.join(', ').html_safe
      end
    end
  end
end
