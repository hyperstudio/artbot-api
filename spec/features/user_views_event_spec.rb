require 'spec_helper'

feature 'User views event' do
  scenario 'and gathers information about the event' do
    event = create(:event)
    create_list(:event, 4)

    visit root_path
    click_on event.name

    expect(page).to display_event_title(event)
    expect(page).to display_event_description(event)
    expect(page).to display_event_image(event)
    expect(page).to display_event_location(event)
    expect(page).to display_event_date(event)
   #  expect(page).to display_related_events_for(event)
    expect(page).to display_ability_to_favorite(event)
  end

  def display_event_title(event)
    have_css 'h2', text: event.name
  end

  def display_event_description(event)
    have_css '.description', text: event.description
  end

  def display_event_image(event)
    have_css "img[src='#{event.image}']"
  end

  def display_event_location(event)
    have_link event.location_name, location_path(event.location)
  end

  def display_event_date(event)
    have_css '.date', text: event.dates
  end

  def display_related_events_for(event)
    event_names = event.related_events.map(&:name)
    have_css('.related', text: /#{event_names.join('.*')}/)
  end

  def display_ability_to_favorite(event)
    have_link 'Favorite', event_favorite_path(event)
  end
end
