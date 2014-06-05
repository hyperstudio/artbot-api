class EventCreator
    def initialize(scraper_result, location_id)
        @event = Event.find_or_initialize_by(url: self.strip_query_params_from_url(scraper_result[:url]))
        @event.name = scraper_result[:name].strip
        @event.description = scraper_result[:description].strip
        @event.dates = scraper_result[:dates].strip
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

    attr_reader :event
end