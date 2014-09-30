class EventCheckupPreview < ActionMailer::Preview
  def event_checkup
    new_event = Event.first
    AdminMailer.event_checkup([[new_event, "image", "404"]])
  end
end