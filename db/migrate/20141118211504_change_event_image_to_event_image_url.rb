class ChangeEventImageToEventImageUrl < ActiveRecord::Migration
  def self.up
    rename_column :events, :image, :image_url
    rename_column :locations, :image, :image_url
  end

  def self.down
    rename_column :events, :image_url, :image
    rename_column :locations, :image_url, :image
  end
end
