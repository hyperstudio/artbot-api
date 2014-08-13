require 'spec_helper'

describe FavoriteSerializer do
  it 'includes event information' do
    favorite = create(:favorite)
    serializer = described_class.new(favorite)
    json = serializer.as_json

    event = json[:favorite][:event]
    expect(event.keys).to include(:event_type)
    expect(event[:location].keys).to include(:id, :name)
  end
end
