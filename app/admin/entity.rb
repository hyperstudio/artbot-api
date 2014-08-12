ActiveAdmin.register Entity do
  remove_filter :entities_events, :entities_tag_sources

  filter :name
  filter :tag_sources, as: :check_boxes
  filter :genres, :label => 'Admin Tags', :collection => proc {TagSource.admin.owned_tags}
  filter :events, :collection => proc {Event.order('name')}

  index do
    selectable_column
    id_column
    column :name
    column :url
    column :entity_type
    column :tag_list
    column "Events" do |entity|
      #entity.events.map {|event| link_to event.name, event}.join(', ')
      entity.events.pluck('name').join(', ')
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
      f.input :events
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :url
      row :description
      row :tag_list
      row :events
    end
  end

  batch_action :tag, confirm: "Add tags (comma separated)", form: {
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
end

