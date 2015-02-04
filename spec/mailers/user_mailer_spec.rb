require 'spec_helper'

describe UserMailer do

    it "sends a weekly digest" do
        user = create(:user, email: 'not_an_admin@example.com')

        new_event = create(:event)
        other_new_event = create(:event)
        mailer = described_class.weekly_digest(user, [new_event], [other_new_event], [], [])
        mailer.deliver

        last_email.multipart?.should be_true
        last_email.should_not be_nil
        last_email.to.should include(user.email)
        last_email.subject.should eq('Artbot weekly digest')
        last_email.parts[0].body.should include(new_event.name, other_new_event.name)
    end

    it "sends an event reminder" do
        user = create(:user, email: 'not_an_admin@example.com')

        new_event = create(:event)
        other_upcoming_event = create(:event)
        third_upcoming_event = create(:event)
        mailer = described_class.event_reminder(user, new_event, [other_upcoming_event, third_upcoming_event])
        mailer.deliver

        last_email.multipart?.should be_true
        last_email.should_not be_nil
        last_email.to.should include(user.email)
        last_email.subject.should include(new_event.name)
        last_email.parts[0].body.should include(new_event.name, other_upcoming_event.name, third_upcoming_event.name)
    end

    it "takes custom options" do
        user = create(:user, email: 'not_an_admin@example.com')
        fake_user = {email: 'not_an_admin@example.com'}
        new_event = create(:event)
        other_new_event = create(:event)

        opts = {cc: fake_user[:email]}
        mailer = described_class.weekly_digest(user, [new_event], [other_new_event], [], [], opts)
        mailer.deliver

        last_email.cc.should include(fake_user[:email])
    end
end
