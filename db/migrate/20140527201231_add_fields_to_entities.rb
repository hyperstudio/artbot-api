class AddFieldsToEntities < ActiveRecord::Migration
  def change
    add_column :entities, :source_name, :string
    add_column :entities, :calais_entity_type, :string
    add_column :entities, :score, :float
    add_column :entities, :calais_type_group, :string
  end
end
