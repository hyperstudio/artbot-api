class AddImageToEvents < ActiveRecord::Migration
  def self.up
    add_attachment :locations, :image
    add_attachment :events, :image
  end

  def self.down
    remove_attachment :locations, :image
    remove_attachment :events, :image
  end
end
