require 'spec_helper'

feature 'User authenticates to the API', js: true do
  include CurbHelpers

  scenario 'and gets a token in response' do
    password = 'fakepassword'
    user = create(:user, email: 'foo@example.com', password: password)
    curb = post_to_api('/tokens', { email: user.email, password: password })

    expect(curb.response_code).to eq 200
    expect(curb.body_str).to include user.authentication_token
  end

  context 'via regular parameters' do
    scenario 'and can request an authenticated resource' do
      user = create(:user)
      event = create(:event)
      favorite = create(:favorite, user: user, event: event)

      curb = get_from_api('/favorites', { authentication_token: user.authentication_token })

      json_response = parse_response_from(curb)

      expect(json_response['favorites'].map{|favorite| favorite['id']}).to include(favorite.id)
    end
  end

  context 'via http headers' do
    scenario 'and can request an authenticated resource' do
      user = create(:user)
      event = create(:event)
      favorite = create(:favorite, user: user, event: event)

      curb = get_from_api('/favorites') do |curl|
        curl.headers['AUTHENTICATION_TOKEN'] = user.authentication_token
      end

      expect(curb.response_code).to eq 200
      json_response = parse_response_from(curb)

      expect(json_response['favorites'].map{|favorite| favorite['id']}).to include(favorite.id)
    end

  end
end
