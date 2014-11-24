require 'spec_helper'

feature 'User requests events', js: true do
  include CurbHelpers

  scenario 'and is looking for a single one' do
    location_name = 'A sweet location'
    location = create(:location, name: location_name)
    event = create(:event, location: location)

    curb = get_from_api(
      "/events/#{event.id}"
    )

    json_response = parse_response_from(curb)
    json_event = json_response['event']

    expect(json_event['id']).to eq event.id
    expect(json_event['location']['name']).to eq location_name
  end

  scenario 'by location' do
    location_name = 'An awesome name'
    location = create(:location, name: location_name)
    first_event = create(:event, :as_current_event, location: location)
    last_event = create(:event, :as_current_event, location: location)
    past_event = create(:event, :as_past_event, location: location)

    curb = get_from_api(
      "/locations/#{location.id}/events"
    )

    json_response = parse_response_from(curb)
    first_event_from_json = json_response['events'].first
    event_ids = get_event_ids_from(json_response)

    expect(first_event_from_json['location']['name']).to eq location_name
    expect(first_event_from_json['id']).to eq first_event.id
    expect(event_ids).to include(first_event.id, last_event.id)
    expect(event_ids).to eq [first_event.id, last_event.id]
    expect(event_ids).not_to include(past_event.id)
  end

  scenario 'near specific coordinates' do
    nearby_location = create(:location, latitude: 42.3394675, longitude: -71.0948962)
    distant_location = create(:location, latitude: -34.6037232, longitude: -58.3815931)

    nearby_event = create(:event, :as_current_event, location: nearby_location)
    past_event = create(:event, :as_past_event, location: nearby_location)
    distant_event = create(:event, :as_current_event, location: distant_location)

    curb = get_from_api(
      "/events",
      {
        latitude: 42.360844,
        longitude: -71.087723
      }
    )

    json_response = parse_response_from(curb)
    event_ids = json_response['events'].map {|e| e['id']}
    expect(event_ids).to include(nearby_event.id)
    expect(event_ids).to eq [nearby_event.id]
    expect(event_ids).not_to include(distant_event.id, past_event.id)
  end

  scenario 'by date' do
    event_ending_today = create(:event, start_date: now - 2.days, end_date: now)
    old_event = create(:event, start_date: now - 4.years, end_date: now - 2.years)
    event_ending_next_month = create(:event, start_date: now - 1.month, end_date: now + 1.month)
    event_ended_yesterday = create(:event, start_date: now - 2.days, end_date: now - 1.day)

    with_a_time_limited_query_for(
      { year: now.year }
    ) do |event_ids|
      unless now.month == 1 && now.day == 1
        expect(event_ids).to eq [event_ended_yesterday.id, event_ending_today.id, event_ending_next_month.id]
        expect(event_ids).not_to include(old_event.id)
      else
        expect(event_ids).to eq [event_ending_today.id, event_ending_next_month.id]
        expect(event_ids).not_to include(old_event.id, event_ended_yesterday.id)
      end
    end

    with_a_time_limited_query_for(
      { year: now.year, month: now.month }
    ) do |event_ids|
      unless now.day == 1
        expect(event_ids).to eq [event_ended_yesterday.id, event_ending_today.id, event_ending_next_month.id]
        expect(event_ids).not_to include(old_event.id)
      else
        expect(event_ids).to eq [event_ending_today.id, event_ending_next_month.id]
        expect(event_ids).not_to include(old_event.id, event_ended_yesterday.id)
      end
    end
    
    event_that_hasnt_started_yet = create(:event, start_date: now + 1.day, end_date: now + 1.month)

    with_a_time_limited_query_for(
      { year: now.year, month: now.month, day: now.day }
    ) do |event_ids|
      expect(event_ids).to eq [event_ending_today.id, event_ending_next_month.id]
      expect(event_ids).not_to include(old_event.id, event_ended_yesterday.id, event_that_hasnt_started_yet.id)
    end
  end
  
  scenario 'related to a single event' do
    event = create(:event, :as_current_event)

    top_related_event = create(:event, :as_current_event)
    lesser_related_event = create(:event, :as_current_event)
    entity_related_event = create(:event, :as_current_event)
    unrelated_event = create(:event, :as_current_event)
    past_event = create(:event, :as_past_event)

    admin_entity = create(:entity, events: [event, top_related_event, past_event])
    entity = create(:entity, events: [event, lesser_related_event, past_event])
    matching_entity = create(:entity, name: entity.name, events: [entity_related_event], entity_type: 'person')

    admin_tag = create(:tag)
    tag = create(:tag)
    admin_tagging = create(:tagging, tagger: create(:admin_source), taggable: admin_entity, tag: admin_tag)
    normal_tagging = create(:tagging, tagger: create(:tag_source), taggable: entity, tag: tag)

    curb = get_from_api(
      "/events/#{event.id}",
      {:related => true}
    )
    json_response = parse_response_from(curb)
    results = json_response['event']['related']

    ordered_tag_names = results.map {|result| result['tag']['name']}
    ordered_event_ids = results.map {|result| result['events'].map {|event| event['id']}}.flatten
    
    expect(ordered_tag_names).to eq [admin_tag.name, tag.name, entity.name]
    expect(ordered_event_ids).to include(top_related_event.id, lesser_related_event.id,
                                         entity_related_event.id)
    expect(ordered_event_ids).to eq [top_related_event.id,
                                     lesser_related_event.id,
                                     entity_related_event.id]
    expect(ordered_event_ids).not_to include(event.id, unrelated_event.id, past_event.id)
  end

  scenario 'and does not want related events' do
    event = create(:event)
    related_event = create(:event)
    entity = create(:entity, events: [event, related_event], entity_type: 'person')

    curb = get_from_api(
      "/events/#{event.id}",
      {:related => false}
    )
    json_response = parse_response_from(curb)
    results = json_response['event']

    expect(results).not_to have_key('related')
  end

  def get_event_ids_from(json_response)
    event_ids = json_response['events'].map { |event| event['id'] }
  end

  def with_a_time_limited_query_for(query)
    curb = get_from_api(
      '/events',
      query
    )

    json_response = parse_response_from(curb)
    event_ids = get_event_ids_from(json_response)

    event_ids = json_response['events'].map { |event| event['id'] }
    yield event_ids
  end

  def now
    @now ||= DateTime.now
  end
end
