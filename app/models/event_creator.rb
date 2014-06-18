class EventCreator
    def initialize(scraper_result, location_id)
        @event = Event.find_or_initialize_by(url: self.strip_query_params_from_url(scraper_result[:url]))
        @event.name = scraper_result[:name].strip
        @event.description = scraper_result[:description].strip
        @event.dates = scraper_result[:dates].strip
        self.assign_datetimes
        @event.image = scraper_result[:image]
        @event.location_id = location_id
    end

    def strip_query_params_from_url(url)
        # Strips everything after a query param ("?") or hash ("#") in a URL string
        (0..url.length).each do |i|
            if (url[i] == "?" or url[i] == "#")
                url = url[0..i-1]
                break
            end
        end
        return url
    end

    def assign_datetimes
        dates = DateParser.parse(@event.dates)
        @event.start_date = dates[0]
        @event.end_date = dates[1]
        @event.event_type == self.is_exhibition? ? "exhibition" : "event"
    end

    def is_exhibition?
        if @event.start_date.nil?
            result = true # assume it's multiple days
        elsif @event.end_date.nil?
            result = false # assume it's only one day
        else
            start_year, start_month, start_day = @event.start_date.year, @event.start_date.month, @event.start_date.day
            end_year, end_month, end_day = @event.end_date.year, @event.end_date.month, @event.end_date.day
            if start_year == end_year and start_month == end_month and start_day == end_day
                # Only lasts one day -- it's an event
                result = false
            else
                result = true
            end
        end
    end

    attr_reader :event
end