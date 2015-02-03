class AdminMailer < ActionMailer::Base
    default to: Proc.new { User.where(admin: true).pluck(:email) },
            template_path: 'mailers'

    def rake_scrape(new_events, changed_events, errors)
        @new_events = new_events
        @changed_events = changed_events
        @errors = errors
        mail(
            :template_name => 'admin_scraper',
            :subject => 'Scraper update'
        )
    end
end