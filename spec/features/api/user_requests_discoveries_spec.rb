require 'spec_helper'

feature 'User requests discoveries', js: true do
  include CurbHelpers

  scenario 'not authenticated' do
    first_event = create(:event, :as_current_event)
    next_event = create(:event, end_date: DateTime.now + 2.days)
    past_event = create(:event, :as_past_event)
    near_future_event = create(:event, :as_near_future_event)
    far_future_event = create(:event, :as_far_future_event)

    curb = get_from_api('/discoveries')
    json_response = parse_response_from(curb)
    event_ids = json_response['events'].map { |event| event['id'] }

    expect(curb.response_code).to eq 200
    expect(event_ids).to  eq [first_event.id, next_event.id, near_future_event.id]
  end

  scenario 'authenticated' do
    # It should return these
    interesting_current_event = create(:event, :as_current_event)
    interesting_next_event = create(:event, end_date: DateTime.now + 2.days)
    # It should not return these
    uninteresting_current_event = create(:event, :as_current_event)
    interesting_past_event = create(:event, :as_past_event)
    interesting_favorited_current_event = create(:event, :as_current_event)
    
    entity = create(:entity, events: [
      interesting_current_event,
      interesting_next_event, 
      interesting_past_event,
      interesting_favorited_current_event])
    tag = create(:tag)
    tagging = create(:tagging, tagger: create(:admin_source), taggable: entity, tag: tag)

    user = create(:user)
    interest = create(:interest, user: user, tag: tag)
    favorite = create(:favorite, user: user, event: interesting_favorited_current_event)

    curb = get_from_api(
      '/discoveries',
      { authentication_token: user.authentication_token }
    )

    json_response = parse_response_from(curb)
    event_ids = json_response['events'].map { |event| event['id'] }

    expect(curb.response_code).to eq 200
    expect(event_ids).to  eq [interesting_current_event.id, interesting_next_event.id]
    expect(event_ids).not_to include(uninteresting_current_event.id, 
                                     interesting_past_event.id, 
                                     interesting_favorited_current_event.id)
  end

  scenario 'authenticated without interests or favorites' do
    user = create(:user)
    event = create(:event, :as_current_event)

    curb = get_from_api(
      '/discoveries',
      {authentication_token: user.authentication_token}
    )

    json_response = parse_response_from(curb)
    
    expect(curb.response_code).to eq 200
    expect(json_response['events'][0]['id']).to eq event.id
  end
end
