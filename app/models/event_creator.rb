class EventCreator
    def initialize(scraper_result, location_id)
        scraper_result = scraper_result.symbolize_keys!
        @event = Event.find_or_initialize_by(url: self.strip_query_params_from_url(scraper_result[:url]))
        @event.name = scraper_result[:name].strip
        @event.description = scraper_result[:description].strip
        @event.dates = scraper_result[:dates].strip
        @event.image = scraper_result[:image]
        @event.location_id = location_id
    end

    def description_changed?
        @event.description_changed?
    end

    def changed?
        @event.changed?
    end

    def new_record?
        @event.new_record?
    end

    def fetch_entities
        @event.fetch_entities
    end

    def save
        @event.save
    end

    def event
        @event
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
end