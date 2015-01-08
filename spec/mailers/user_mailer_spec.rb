require 'spec_helper'

describe UserMailer do

    it "sends a weekly digest" do
        user = create(:user, email: 'not_an_admin@example.com')

        new_event = create(:event)
        other_new_event = create(:event)
        mailer = described_class.weekly_digest(user, [new_event], [other_new_event], [], [])
        mailer.deliver

        last_email.should_not be_nil
        last_email.to.should include(user.email)
        last_email.subject.should eq('Artbot weekly digest')
        last_email.body.should include(new_event.name, other_new_event.name)
    end
end