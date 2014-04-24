class AddFieldsToEventsAndLocations < ActiveRecord::Migration
  def change
    change_table :events do |t|
      t.integer :location_id
      t.string :name
      t.string :url
      t.text :description
      t.string :image
      t.string :type
    end

    change_table :locations do |t|
      t.string :name
      t.string :url
      t.text :description
      t.string :image
      t.string :type
      t.float :latitude
      t.float :longitude
    end
  end
end
