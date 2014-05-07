require 'spec_helper'

describe Guest, '#favorited_events' do
  it 'returns recent events' do
    event_list = create_list :event, 6
    expect(Guest.new.favorited_events).to match_array event_list.last(5)
  end
end
