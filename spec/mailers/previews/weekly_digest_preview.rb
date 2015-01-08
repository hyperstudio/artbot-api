class WeeklyDigestPreview < ActionMailer::Preview
  def weekly_digest
  	user = User.first
    new_event = Event.first
    UserMailer.weekly_digest(user, [new_event], [], [], [])
  end
end