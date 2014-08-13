class AddIndexesToEventEndDates < ActiveRecord::Migration
  def change
    execute 'create index events_end_date_year_index on events (extract(year from end_date))'
    execute 'create index events_end_date_month_index on events (extract(month from end_date))'
    execute 'create index events_end_date_day_index on events (extract(day from end_date))'
  end
end
