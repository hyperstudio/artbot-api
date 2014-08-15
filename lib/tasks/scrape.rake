namespace :scrape do
    desc 'run scrapers and entity recognition for museum websites'
    task :all => :environment do
        ALL_NER_PATHS = ['stanford', 'opencalais', 'zemanta']
        # Start with all of the URLs in the database
        ScraperUrl.all.find_each do |url|
            puts "Querying scraper app with %s" % url.url
            # This is where we query the scraper app
            url.query_scraper_app.each do |event_result|
                event = EventCreator.new(event_result, url.location_id).event
                if event.description_changed?
                    # Either the record is new or has changed, so re-categorize it
                    event.save
                    # Query the NER app here
                    puts "...New event, %s, querying NER" % event.url
                    ALL_NER_PATHS.each {|path| event.get_and_process_entities(path)}
                elsif event.changed?
                    event.save
                end
            end
        end
    end
end
