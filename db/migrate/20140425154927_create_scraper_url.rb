class CreateScraperUrl < ActiveRecord::Migration
  def change
    create_table :scraper_urls do |t|
      t.string :url
      t.integer :location_id
    end
  end
end
