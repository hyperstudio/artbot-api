require 'spec_helper'

describe Event, '#related_events' do

  it { should have_many(:favorites).dependent(:destroy) }
  it { should have_many(:users).through(:favorites) }

  it 'seeds events with default time values' do
    event = create(:event)
    expect(event.start_date.day).to eq Time.now.day
  end
end
