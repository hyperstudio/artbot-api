require 'spec_helper'

describe Location, '#newest_events' do
  it 'returns the newest events it owns' do
    location = create :location
    events = create_list :event, 6, location: location

    expect(location.newest_events).to match_array events.last(5)
  end
end
