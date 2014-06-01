class CleanupEntities < ActiveRecord::Migration
  def change
    rename_column :entities, :calais_entity_type, :entity_type
    rename_column :entities, :calais_type_group, :type_group
    reversible do |dir|
        dir.up do
            Entity.where(source_name: "DBpedia", url: nil).find_each do |entity|
                entity.source_name = "Stanford"
                entity.name = entity.stanford_name
                entity.entity_type = entity.stanford_type
                entity.save
            end
        end
        dir.down do
            Entity.where(source_name: "Stanford").find_each do |entity|
                entity.source_name = "DBpedia"
                entity.stanford_name = entity.name
                entity.stanford_type = entity.entity_type
                entity.save
            end
        end
    end
    remove_column :entities, :stanford_type, :string
  end
end
