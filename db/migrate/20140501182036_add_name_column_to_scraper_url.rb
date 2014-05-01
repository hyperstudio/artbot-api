class AddNameColumnToScraperUrl < ActiveRecord::Migration
  def change
    add_column :scraper_urls, :name, :string
  end
end
