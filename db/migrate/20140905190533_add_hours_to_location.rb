class AddHoursToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :hours, :string
  end
end
