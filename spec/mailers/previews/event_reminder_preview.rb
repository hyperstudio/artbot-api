class EventReminderPreview < ActionMailer::Preview
	def event_reminder
		user = User.first
		events = Event.take(3)
		UserMailer.event_reminder(user, events[0], events[1..2])
	end
end