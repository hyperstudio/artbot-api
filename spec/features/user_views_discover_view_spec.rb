require 'spec_helper'

feature 'User visits discover view' do
  scenario 'and learns more about various events' do
    event = create(:event)
    event_2 = create(:event)
    event_3 = create(:event)

    visit root_path

    expect(page).to display_primary_event(event)
    expect(page).to display_favorited_events(event_3, event_2)
    expect(page).not_to display_favorited_events(event)
  end

  def display_primary_event(event)
    have_css('.event.primary', text: event.name)
  end

  def display_favorited_events(*events)
    event_names = events.map &:name
    have_css('.event.favorites', text: /#{event_names.join('.*')}/)
  end
end
