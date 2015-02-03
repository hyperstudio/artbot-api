class WeeklyDigestPreview < ActionMailer::Preview
  def weekly_digest
  	user = User.first
  	events = Event.take(8)
    UserMailer.weekly_digest(user, events[0..1], events[2..3], events[4..5], events[6..7])
  end
end