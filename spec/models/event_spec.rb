require 'spec_helper'

describe Event, '#related_events' do
  it 'returns the newest events excluding itself' do
    events = create_list :event, 3
    event = events.first

    expect(event.related_events).to match_array events.last(2)
  end
end
