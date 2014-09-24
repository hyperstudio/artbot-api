class UpdateImagesPreview < ActionMailer::Preview
  def update_images
    new_event = Event.first
    AdminMailer.update_images([[new_event, "404"]])
  end
end