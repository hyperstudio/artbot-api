class CreateDbpediaEntity < ActiveRecord::Migration
  def change
    create_table :dbpedia_entities do |t|
        t.string :name
        t.string :url
        t.text :description
        t.integer :refCount
    end
  end
end
