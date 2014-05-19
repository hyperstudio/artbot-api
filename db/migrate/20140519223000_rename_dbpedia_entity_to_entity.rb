class RenameDbpediaEntityToEntity < ActiveRecord::Migration
  def change
    rename_table :dbpedia_entities, :entities
    rename_table :dbpedia_entities_events, :entities_events
    rename_column :entities_events, :dbpedia_entity_id, :entity_id
  end
end
