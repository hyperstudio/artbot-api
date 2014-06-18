class AddDatesToEvents < ActiveRecord::Migration
  def change
    add_column :events, :start_date, :datetime
    add_column :events, :end_date, :datetime

    reversible do |dir|
        dir.up do
            Event.all.each do |event|
                dates = DateParser.parse(event.dates)
                event.start_date = dates[0]
                event.end_date = dates[1]

                if dates[0].nil?
                    event.event_type = "exhibition"
                elsif dates[1].nil?
                    event.event_type = "event"
                else
                    start_year, start_month, start_day = event.start_date.year, event.start_date.month, event.start_date.day
                    end_year, end_month, end_day = event.end_date.year, event.end_date.month, event.end_date.day
                    if start_year == end_year and start_month == end_month and start_day == end_day
                        # Only lasts one day -- it's an event
                        event.event_type = "event"
                    else
                        event.event_type = "exhibition"
                    end
                end
                event.save
            end
        end
        dir.down do
        end
    end
  end
end
