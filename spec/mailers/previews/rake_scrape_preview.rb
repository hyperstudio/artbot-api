class ScraperPreview < ActionMailer::Preview
  def scrape
    new_event = Event.first
    AdminMailer.rake_scrape([new_event], [], [])
  end
end