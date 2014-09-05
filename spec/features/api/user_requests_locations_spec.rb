require 'spec_helper'

feature 'User requests locations', js: true do
  include CurbHelpers

  scenario 'and is looking for a single location' do
    location_name = 'A location'
    location = create(:location, name: location_name)

    curb = get_from_api(
      "/locations/#{location.id}"
    )

    json_response = parse_response_from(curb)

    expect(json_response['location']['id']).to eq location.id
    expect(json_response['location']['name']).to eq location_name
  end

  scenario 'and is looking for a paginated list of locations' do
    locations = create_list(:location, 2)

    curb = get_from_api(
      "/locations", { per_page: 1 }
    )

    json_response = parse_response_from(curb)
    first_location = json_response['locations'].first

    expect(json_response['locations']).to have(1).item
    expect(first_location.keys).to include('name','description','latitude','longitude','address','hours')
  end
end
