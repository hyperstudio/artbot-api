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
                        # Check for blacklisted URLs
                        if event.blacklisted?
                            next
                        end
                        changes = event.changed_attributes.keys.to_set
                        if changes.include? 'description'
                            # Either the record is new or has changed, so re-categorize it
                            event.save
                            # Query the NER app here
                            puts "...New event, %s, querying NER" % event.url
                            ALL_NER_PATHS.each {|path| event.get_and_process_entities(path)}
                            new_events << event
                        # Paperclip updates these automatically, so don't let it update the whole record
                        elsif (changes - ['image_updated_at', 'image_file_name'].to_set).present?
                            puts "...Event %s updated" % event.url
                            event.save
                            changed_events << event
                        end
                    rescue Exception => exc
                        msg = "Error on scraper url #{url.url}, event #{event_result[:url]} with message #{exc.message}"
                        errors << msg
                        puts msg
                    end
                end
            rescue Exception => exc
                msg = "Error on scraper url #{url.url} with message #{exc.message}"
                errors << msg
                puts msg
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
            users = User.where(send_weekly_emails: true)
            users.find_each do |user|
                user.delay.send_weekly_digest_email
            end
        end
    end
end

namespace :email do
    desc 'send event close notification emails to users'
    task :reminder => :environment do
        users = User.where("send_week_before_close_reminders = ? OR send_day_before_event_reminders = ?",true,true)
        users.find_each do |user|
            user.delay.send_event_reminder_email
        end
    end
end
