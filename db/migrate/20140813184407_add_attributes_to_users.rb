class AddAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :zipcode, :string
    add_column :users, :send_weekly_emails, :boolean, default: false
    add_column :users, :send_day_before_event_reminders, :boolean, default: false
    add_column :users, :send_week_before_close_reminders, :boolean, default: false
  end
end
