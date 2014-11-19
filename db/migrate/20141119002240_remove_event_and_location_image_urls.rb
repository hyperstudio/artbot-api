class RemoveEventAndLocationImageUrls < ActiveRecord::Migration
  def change
    remove_column :locations, :image_url, :string
    remove_column :events, :image_url, :string
  end
end
