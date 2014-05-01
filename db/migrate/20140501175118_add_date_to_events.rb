class AddDateToEvents < ActiveRecord::Migration
  def change
    # Temporary storage while we figure out proper date formatting
    add_column :events, :dates, :string
  end
end
