ActiveAdmin.register ActsAsTaggableOn::Tag, as: "Tag" do
  permit_params :name
  
  filter :name
  
  index do
    selectable_column
    id_column
    column :name
    column "Entities" do |tag|
      Entity.tagged_with(tag).pluck('name').join(', ')
    end
    column :taggings_count
    actions
  end
end
