require 'spec_helper'

feature 'User manages favorites', js: true do
  include CurbHelpers

  scenario 'paginates' do
    user = create(:user)
    favorites = create_list(:favorite, 2, user: user)

    curb = get_from_api(
      '/favorites',
      {
        authentication_token: user.authentication_token,
        per_page: 1
      }
    )
    json_response = parse_response_from(curb)
    favorite_ids = json_response['favorites'].map{ |favorite| favorite['id'] }

    expect(favorite_ids).to include(favorites.last.id)
    expect(favorite_ids).not_to include(favorites.first.id)
    expect(json_response['meta']).to include('per_page' => '1')
  end

  scenario 'creates a favorite for an event' do
    event = create(:event)
    user = create(:user)

    curb = post_to_api(
      "/events/#{event.id}/favorite",
      {
        authentication_token: user.authentication_token,
        attended: true
      }
    )

    json_response = parse_response_from(curb)

    expect(curb.response_code).to eq 201
    expect(json_response['favorite']['id']).to be
    expect(json_response['favorite']['attended']).to be
  end

  scenario 'destroys a favorite' do
    favorite = create(:favorite)
    user = favorite.user

    curb = delete_via_api(
      "/favorites/#{favorite.id}",
      {
        authentication_token: user.authentication_token
      }
    )

    expect(curb.response_code).to eq 204
  end

  scenario 'finds current favorited events' do
    user = create(:user)
    past_event = create(:event, :as_past_event)
    current_event = create(:event, :as_current_event)

    past_favorite = create(:favorite, user: user, event: past_event)
    current_favorite = create(:favorite, user: user, event: current_event)

    curb = get_from_api(
      "/favorites",
      {
        authentication_token: user.authentication_token
      }
    )

    json_response = parse_response_from(curb)
    favorite_ids = json_response['favorites'].map{ |favorite| favorite['id'] }

    expect(favorite_ids).to include(current_favorite.id)
    expect(favorite_ids).not_to include(past_favorite.id)
  end

  scenario 'finds past favorited events through history' do
    user = create(:user)
    past_event = create(:event, :as_past_event)
    current_event = create(:event, :as_current_event)

    create(:favorite, user: user, event: past_event)
    create(:favorite, user: user, event: current_event)

    curb = get_from_api(
      "/favorites/history",
      {
        authentication_token: user.authentication_token
      }
    )

    json_response = parse_response_from(curb)
    favorite_ids = json_response['favorites'].map{ |favorite| favorite['id'] }
    first_favorite_event = json_response['favorites'].first['event']

    expect(curb.response_code).to eq 200
    expect(favorite_ids).to include(past_event.id)
    expect(favorite_ids).not_to include(current_event.id)
    expect(first_favorite_event['location']['name']).to eq past_event.location_name
  end

  scenario 'sets a favorited event as attended' do
    favorite = create(:favorite, attended: false)
    user = favorite.user

    curb = patch_to_api(
      "/favorites/#{favorite.id}",
      {
        authentication_token: user.authentication_token,
        attended: true
      }
    )

    json_response = parse_response_from(curb)
    expect(json_response['favorite']['attended']).to be_true
  end

  scenario 'unsets a favorited event as attended' do
    favorite = create(:favorite, attended: true)
    user = favorite.user

    curb = patch_to_api(
      "/favorites/#{favorite.id}",
      {
        authentication_token: user.authentication_token,
        attended: false
      }
    )

    json_response = parse_response_from(curb)
    expect(json_response['favorite']['attended']).to be_false
  end
end
