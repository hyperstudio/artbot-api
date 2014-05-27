namespace :scrape do
    desc 'run scrapers and entity recognition for museum websites'
    task :all => :environment do
        # Start with all of the URLs in the database
        ScraperUrl.all.find_each do |url|
            # This is where we query the scraper app
            url.query_scraper_app.each do |event_result|
                event = EventCreator.new(event_result, url.location_id).event
                if event.description_changed?
                    # Either the record is new or has changed, so re-categorize it
                    event.save
                    # Query the NER app here
                    ['stanford', 'calais'].each {|tag_source| event.fetch_and_assign_tags(tag_source)}
                elsif event.changed?
                    event.save
                end
            end
        end
    end
end
