require 'spec_helper'

describe EventSerializer do
  it 'includes location information' do
    location_name = 'An awesome place!'
    location = create(:location, name: location_name)
    event = create(:event, location: location)

    serializer = described_class.new(event)

    json = serializer.as_json

    expect(json[:event][:location]['name']).to eq location_name
  end
end
