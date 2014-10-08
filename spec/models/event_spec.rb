require 'spec_helper'

describe Event, '#related_events' do

  it { should have_many(:favorites).dependent(:destroy) }
  it { should have_many(:users).through(:favorites) }
  it { should be_versioned }

  it 'versions a new event', :versioning => true do
    event = create(:event)
    expect(event.versions.count).to eq 1
  end

  it 'versions with a default whodunnit', :versioning => true do
    event = create(:event)
    expect(event.originator).to eq PaperTrail.whodunnit
  end

  it 'does not resave a version that was already saved', :versioning => true do
    event = create(:event, description: 'An old description')
    event.update(description: 'An old description')

    expect(event.versions.count).to eq 1
  end

  it 'does not resave a version that was already saved by a bot', :versioning => true do
    event = create(:event, description: 'An old description')
    event.whodunnit('human_person_1') do
      event.update(description: 'A new description')
    end
    event.update(description: 'An old description')

    expect(event.versions.count).to eq 2
    # Just make sure the latest version didn't save
    expect(event.versions.last.id).to eq nil
  end

  it 'reverts any bot version to the latest admin version', :versioning => true do
    event = create(:event, description: 'An old description')
    event.whodunnit('human_person_1') do
      event.update(description: 'A new description')
    end
    event.update(description: 'An even newer description that should be saved but overridden')

    expect(event.versions.count).to eq 4
    expect(event.versions.last.previous.whodunnit).to eq PaperTrail.whodunnit
    expect(event.originator).to eq 'human_person_1'
  end

  it 'does not version when a related model is created', :versioning => true do
    event = create(:event)
    entity = create(:entity, events: [event])
    user = create(:user)
    favorite = create(:favorite, user: user, event: event)

    expect(event.versions.count).to eq 1
  end

  it 'processes exhibitions with no dates' do
    event = create(:event, dates: '')

    expected_start = Time.now.midnight.utc
    expected_end = expected_start + 1.year

    expect(event.event_type).to eq 'exhibition'
    expect_dates_to_match(event.start_date, expected_start)
    expect_dates_to_match(event.end_date, expected_end)
  end

  it 'processes events with no end date' do
    event = create(:event, dates: 'September 25, 2014')
    
    expected_start = Time.new(2014, 9, 25).utc
    expected_end = expected_start + 1.day - 1.second

    expect(event.event_type).to eq 'event'
    expect_dates_to_match(event.start_date, expected_start)
    expect_dates_to_match(event.end_date, expected_end)
  end

  it 'processes events with valid dates' do
    event = create(:event, dates: 'September 25, 2014 7:00pm - 9:00pm')

    expected_start = Time.new(2014, 9, 25, 19, 0, 0).utc
    expected_end = Time.new(2014, 9, 25, 21, 0, 0).utc

    expect(event.event_type).to eq 'event'
    expect_dates_to_match(event.start_date, expected_start)
    expect_dates_to_match(event.end_date, expected_end)
  end

  it 'processes exhibitions with valid dates' do
    event = create(:event, dates: 'September 25, 2014 - December 12, 2015')

    expected_start = Time.new(2014, 9, 25).utc
    expected_end = Time.new(2015, 12, 12).utc

    expect(event.event_type).to eq 'exhibition'
    expect_dates_to_match(event.start_date, expected_start)
    expect_dates_to_match(event.end_date, expected_end)
  end

  def expect_dates_to_match(first_date, second_date)
    expect(first_date.year).to eq second_date.year
    expect(first_date.day).to eq second_date.day
    expect(first_date.hour).to eq second_date.hour
    expect(first_date.min).to eq second_date.min
    expect(first_date.sec).to eq second_date.sec
  end
end
