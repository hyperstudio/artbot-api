namespace :scrape do
    desc 'run scrapers and entity recognition for museum websites'
    task :all => :environment do
        ALL_NER_PATHS = ['stanford', 'opencalais', 'zemanta']
        new_events = []
        changed_events = []
        errors = []
        # Confirm that we are in bot mode for versioning
        PaperTrail.whodunnit = Rails.application.config.paper_trail_default_whodunnit
        # Start with all of the URLs in the database
        ScraperUrl.all.find_each do |url|
            puts "Querying scraper app with %s" % url.url
            begin
                # This is where we query the scraper app
                url.query_scraper_app.each do |event_result|
                    begin
                        event = EventCreator.new(event_result, url.location_id).event
                        if event.description_changed?
                            # Either the record is new or has changed, so re-categorize it
                            event.save
                            # Query the NER app here
                            puts "...New event, %s, querying NER" % event.url
                            ALL_NER_PATHS.each {|path| event.get_and_process_entities(path)}
                            new_events << event
                        elsif event.changed?
                            puts "...Event %s updated" % event.url
                            event.save
                            changed_events << event
                        end
                    rescue
                        errors << @error_message
                        puts "...ERROR %s" % @error_message
                    end
                end
            rescue
                errors << @error_message
                puts "...ERROR %s" % @error_message
            end
        end
        if new_events.present? || changed_events.present? || errors.present?
            AdminMailer.delay.rake_scrape(new_events, changed_events, errors)
        end
    end
end

namespace :email do
    desc 'compile and send weekly email to users'
    task :weekly => :environment do
        # Heroku scheduler doesn't have a "weekly" option, so we have to include this
        if Time.now.monday?
            # TODO: once we're confident in these, remove the admin filter
            users = User.where(send_weekly_emails: true, admin: true)
            users.find_each do |user|
                user.delay.send_weekly_digest_email
            end
        end
    end
end

namespace :email do
    desc 'send event close notification emails to users'
    task :reminder => :environment do
        # TODO: once we're confident in these, remove the admin filter
        users = User.where(send_weekly_emails: true, admin: true)
        users.find_each do |user|
            user.delay.send_event_reminder_email
        end
    end
end
