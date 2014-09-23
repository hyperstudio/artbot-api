require 'spec_helper'

describe AdminMailer do

    it "sends a scraper update" do
        admin_user = create(:user, email: 'admin@example.com', admin: true)
        regular_user = create(:user, email: 'not_an_admin@example.com')

        new_event = create(:event)
        other_new_event = create(:event)
        mailer = described_class.rake_scrape([new_event, other_new_event], [], [])
        mailer.deliver

        mailer.to.should include(admin_user.email)
        mailer.to.should_not include(regular_user.email)
        mailer.subject.should eq('Scraper update')
        mailer.body.should include(new_event.name, other_new_event.name)
    end

end