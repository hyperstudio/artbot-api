require 'spec_helper'

feature 'A user manages their account', js: true do
  include CurbHelpers

  context 'creation' do
    scenario 'by signing up for one correctly' do
      curb = post_to_api(
        '/registrations',
        {
          'email' => 'foo@example.com',
          'password' => '1234qwer',
          'password_confirmation' => '1234qwer',
          'zipcode' => '01902'
        }
      )
      json_response = parse_response_from(curb)

      expect(json_response['user'].keys).to include('email', 'zipcode','authentication_token')
    end

    scenario 'by signing up for one incorrectly' do
      curb = post_to_api(
        '/registrations', { 'email' => 'foo' }
      )
      json_response = parse_response_from(curb)

      expect(curb.response_code).to eq 422
      expect(json_response).to include('email' => ['is invalid'])
      expect(json_response).to include('password' => ["can't be blank"])
    end
  end

  context 'existence' do
    scenario 'by asking whether they exist correctly' do
      user = create(:user)
      curb = head_from_api(
        '/registrations',
        { 'email' => user.email }
      )

      expect(curb.body).to eq ""
      expect(curb.response_code).to eq 200
    end

    scenario 'by asking whether they exist incorrectly' do
      curb = head_from_api(
        '/registrations',
        { 'email' => 'nonexistent_email@example.com' }
      )

      expect(curb.body).to eq ""
      expect(curb.response_code).to eq 404
    end
  end

  context 'preferences' do
    scenario 'by requesting preferences' do
      user = create(:user)

      curb = get_from_api(
        '/preferences', { authentication_token: user.authentication_token }
      )

      expect(curb.response_code).to eq 200
      json_user = parse_response_from(curb)['user']

      expect(json_user['email']).to eq user.email
      expect(json_user.keys).to include(
        'send_weekly_emails',
        'send_week_before_close_reminders',
        'zipcode',
        'email'
      )
      expect(json_user.keys).not_to include(
        'password'
      )
    end

    scenario 'by managing preferences' do
      user = create(
        :user,
        send_weekly_emails: false,
        send_day_before_event_reminders: false,
        send_week_before_close_reminders: false
      )

      curb = patch_to_api(
        '/preferences',
        {
          authentication_token: user.authentication_token,
          send_weekly_emails: true,
          send_day_before_event_reminders: true,
          send_week_before_close_reminders: true
        }
      )

      json_user = parse_response_from(curb)['user']

      expect(curb.response_code).to eq 200
      expect(json_user['send_weekly_emails']).to eq true
      expect(json_user['send_week_before_close_reminders']).to eq true
    end
  end
end
