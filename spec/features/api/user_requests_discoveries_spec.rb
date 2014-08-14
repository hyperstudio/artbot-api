require 'spec_helper'

feature 'User requests discoveries', js: true do
  include CurbHelpers

  scenario 'not authenticated' do
    first_event = create(:event, :as_current_event)
    next_event = create(:event, end_date: DateTime.now + 2.days)
    past_event = create(:event, :as_past_event)

    curb = get_from_api('/discoveries')
    json_response = parse_response_from(curb)
    event_ids = json_response['events'].map { |event| event['id'] }

    expect(curb.response_code).to eq 200
    expect(event_ids).to  eq [first_event.id, next_event.id]
  end

  scenario 'authenticated' do
    user = create(:user)
    first_event = create(:event, :as_current_event)
    next_event = create(:event, end_date: DateTime.now + 2.days)
    past_event = create(:event, :as_past_event)

    curb = get_from_api(
      '/discoveries',
      { authentication_token: user.authentication_token }
    )

    json_response = parse_response_from(curb)
    event_ids = json_response['events'].map { |event| event['id'] }

    expect(curb.response_code).to eq 200
    expect(event_ids).to  eq [first_event.id, next_event.id]
  end
end
