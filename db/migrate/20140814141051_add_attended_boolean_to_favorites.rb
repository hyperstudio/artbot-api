class AddAttendedBooleanToFavorites < ActiveRecord::Migration
  def change
    add_column :favorites, :attended, :boolean, default: false
  end
end
