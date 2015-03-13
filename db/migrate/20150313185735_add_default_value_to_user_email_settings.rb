class AddDefaultValueToUserEmailSettings < ActiveRecord::Migration
  def change
  	change_column :users, :send_day_before_event_reminders, :boolean, :default => true
  	change_column :users, :send_week_before_close_reminders, :boolean, :default => true
  	change_column :users, :send_weekly_emails, :boolean, :default => true
  end
end
