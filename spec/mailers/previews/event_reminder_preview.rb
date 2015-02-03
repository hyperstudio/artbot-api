class EventReminderPreview < ActionMailer::Preview
	def event_reminder
		user = User.first
		suggested_events = user.prepare_event_reminder_email(Event.first)
		closing_event = Event.first
		if closing_event.present?
			suggested_events = user.prepare_event_reminder_email(closing_event)
			UserMailer.event_reminder(user, *suggested_events)
		end
	end
end
