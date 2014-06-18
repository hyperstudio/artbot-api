class AddEventTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :event_type, :string, :default => "exhibition"
  end
end
