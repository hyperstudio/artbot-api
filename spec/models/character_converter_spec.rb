require 'spec_helper'

describe CharacterConverter do
  it 'fixes strings with mixed character sets' do
    good_string = "hello ümlaut "
    expect(described_class.convert_to_unicode(good_string)).to eq good_string
  end
end
