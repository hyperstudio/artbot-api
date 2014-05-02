class AddTypeToDbpediaEntities < ActiveRecord::Migration
  def change
    add_column :dbpedia_entities, :stanford_type, :string
    add_column :dbpedia_entities, :stanford_name, :string
  end
end
