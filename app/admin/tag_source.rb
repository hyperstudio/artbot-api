ActiveAdmin.register TagSource do
  permit_params :name
  remove_filter :tagsources_entities
end
