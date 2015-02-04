class WeeklyDigestPreview < ActionMailer::Preview
  def weekly_digest
  	user = User.first
  	events = user.prepare_weekly_email
    UserMailer.weekly_digest(user, *events, {cc: 'test@example.com'})
  end
end