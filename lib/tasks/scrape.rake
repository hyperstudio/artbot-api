namespace :scrape do
    desc 'run scrapers and entity recognition for museum websites'
    task :all => :environment do
        # Start with all of the URLs in the database
        ScraperUrl.all.find_each do |url|
            # This is where we query the scraper app
            url.query_scraper_app.each do |event_result|
                event_creator = EventCreator.new(event_result, url.location_id)
                if event_creator.description_changed?
                    # Either the record is new or has changed, so re-categorize it
                    event_creator.save
                    # Query the NER app here
                    event_creator.fetch_entities.each do |entity_result|
                        entity_creator = EntityCreator.new(entity_result)
                        entity_creator.save
                        # Tie it to its source
                        EntityAssociator.new(event_creator.event, entity_creator.entity).process_dbpedia(entity_creator.categories) if entity_creator.categories.present?
                    end
                elsif event_creator.changed?
                    event_creator.save
                end
            end
        end
    end
end
