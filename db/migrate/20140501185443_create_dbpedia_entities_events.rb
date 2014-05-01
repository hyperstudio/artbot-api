class CreateDbpediaEntitiesEvents < ActiveRecord::Migration
  def change
    create_table :dbpedia_entities_events, id: false do |t|
        t.belongs_to :event
        t.belongs_to :dbpedia_entity
    end
  end
end
