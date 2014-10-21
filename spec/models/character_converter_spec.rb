require 'spec_helper'

describe CharacterConverter do
  it 'fixes strings with mixed character sets' do
    good_string = "hello ümlaut "
    expect(described_class.convert_to_unicode(good_string)).to eq good_string
  end
  it 'encodes strings as uris' do
    bad_uri = "http://mfas3.s3.amazonaws.com/styles/banner_grid-9_retina/s3/Train close ip2 yellow light2_4x3_0.jpg?itok=A1qZeqn0"
    expected_result = "http://mfas3.s3.amazonaws.com/styles/banner_grid-9_retina/s3/Train%20close%20ip2%20yellow%20light2_4x3_0.jpg?itok=A1qZeqn0"
    expect(described_class.encode_uri(bad_uri)).to eq expected_result
  end
  it 'does not encode uris that are already encoded' do
    ok_uri = "http://mfas3.s3.amazonaws.com/styles/banner_grid-6_retina/s3/Fenway%20at%20dusk_0.jpg"
    expect(described_class.encode_uri(ok_uri)).to eq ok_uri
  end
end
