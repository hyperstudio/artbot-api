require 'spec_helper'

feature 'User views location' do
  scenario 'and sees relevant information' do
    event = create(:event)
    location = event.location
    create_list :event, 2, location: location

    visit root_path
    click_on event.name
    click_on event.location_name

    expect(page).to display_location_name(location)
    expect(page).to display_map(location)
    expect(page).to display_image(location)
    expect(page).to display_description(location)
    expect(page).to display_newest_events_for(location)
  end

  def display_location_name(location)
    have_css('h3', location.name)
  end

  def display_map(location)
    have_css("a[href*='#{location.latitude}'] img[src*='#{location.latitude}']")
  end

  def display_image(location)
    have_css("img[src='#{location.image}']")
  end

  def display_description(location)
    have_css('p', text: location.description.squish)
  end

  def display_newest_events_for(location)
    event_names = location.newest_events.map(&:name)
    have_css('.newest-events', text: /#{event_names.join('.*')}/)
  end
end
