require 'spec_helper'

feature 'User visits discover view' do
  scenario 'and learns more about various events' do
    event = create(:event)
    visit root_path
    expect(page).to display_primary_event(event)
  end

  def display_primary_event(event)
    have_css('.event.primary', text: event.name)
  end
end
