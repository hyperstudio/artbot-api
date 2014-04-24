class RemoveTypeFromEventAndLocation < ActiveRecord::Migration
  def change
    remove_column :events, :type, :string
    remove_column :locations, :type, :string
  end
end
