class ChangeEntityToTagSourceRelationship < ActiveRecord::Migration
  def change
    tag_sources = TagSource.all
    reversible do |dir|
        dir.up do
            Entity.all.find_each do |e|
                e.tag_sources += [tag_sources.find_by_name(e.source_name)]
            end
        end
        dir.down do
            Entity.all.find_each do |e|
                e.source_name = e.tag_sources.first
            end
        end
    end
    remove_column :entities, :source_name, :string
  end
end
