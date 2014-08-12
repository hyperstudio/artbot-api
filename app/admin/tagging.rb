ActiveAdmin.register ActsAsTaggableOn::Tagging, as: "Tagging" do
  filter :tagger_id, as: :check_boxes, collection: proc {TagSource.all}
  filter :taggable_id, as: :select, label: "Entity", collection: proc {Entity.all}
  filter :tag_id, as: :select, label: "Tag", collection: proc {ActsAsTaggableOn::Tag.all}
  #filter :tag_id, as: :select, label: "Admin Tag", collection: proc {TagSource.admin.owned_tags}

  index do
    selectable_column
    id_column
    column "Entity" do |tagging|
      Entity.find(tagging.taggable_id).name
    end
    column "Tag" do |tagging|
      ActsAsTaggableOn::Tag.find(tagging.tag_id).name
    end
    column "Source" do |tagging|
      TagSource.find(tagging.tagger_id).name
    end
    column :context
  end
end
