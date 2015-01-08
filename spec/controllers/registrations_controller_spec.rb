require 'spec_helper'

describe RegistrationsController do
  context '#show' do
    it 'checks if a user exists' do
      user = create(:user, email: 'foobar@example.com')

      head :show, { email: user.email }

      expect(response.code.to_i).to eq 200
      expect(response.body.strip).to be_empty
    end

    it 'sends a 404 if a user does not exist' do
      head :show, { email: 'fake@notanemail.com' }

      expect(response.code.to_i).to eq 404
      expect(response.body.strip).to be_empty
    end
  end

  context '#create' do
    it 'creates a user' do
      params = {
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'password',
        zipcode: '11211'
      }

      post :create, params

      expect(response.code.to_i).to eq 200

      json_response = ActiveSupport::JSON.decode(response.body)['user']
      expect(json_response['email']).to eq params[:email]
      expect(json_response['zipcode']).to eq params[:zipcode]
      # User should default to being remembered indefinitely
      expect(json_response['remember_created_at']).not_to eq nil
    end
  end

  context '#update' do
    it 'updates a user password' do
      user = create(:user, password: 'old_password', reset_password_token: 'foobar')

      request.env['reset_password_token'] = user.reset_password_token
      put :update, { 
        password: 'new_password', 
        password_confirmation: 'new_password'
      }

      # No good way here to check if the password actually changed...
      expect(response.code.to_i).to eq 200
    end
    it 'returns an error if the password confirmation does not match' do
      user = create(:user, password: 'old_password', reset_password_token: 'foobar')

      put :update, {
        password: 'new_password',
        password_confirmation: 'non_matching_password',
        reset_password_token: user.reset_password_token
      }

      expect(response.code.to_i).to eq 422
    end
    it 'returns a 404 if the user does not exist' do
      user = create(:user, password: 'old_password', reset_password_token: 'foobar')

      put :update, {
        password: 'new_password',
        password_confirmation: 'new_password',
        reset_password_token: 'invalid_reset_token'
      }

      expect(response.code.to_i).to eq 404
    end
    it 'returns an error if no token is provided' do
      user = create(:user, password: 'old_password')

      put :update, {
        password: 'new_password',
        password_confirmation: 'new_password'
      }

      expect(response.code.to_i).to eq 422
    end
  end

  context '#send_reset_email' do
    it 'sends a password reset email' do
      user = create(:user, email: 'foobar@example.com')

      patch :send_reset_email, { email: user.email }

      # TODO: add test to ensure delivery of email. It works in console but not in test.
      expect(response.code.to_i).to eq 200
      expect(response.body.strip).to be_empty
    end
    it 'sends a 404 if the user does not exist' do
      patch :send_reset_email, { email: 'foobar@example.com' }

      expect(response.code.to_i).to eq 404
    end
  end
end