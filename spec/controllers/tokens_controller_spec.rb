require 'spec_helper'

describe TokensController do
  context '#show' do
    it 'checks if a user exists' do
      user = build(
        :user,
        email: 'foobar@example.com',
        password: 'password'
      )

      head :show, { email: user.email }

      expect(response).to be_request_ok
      expect(response.body).to be_empty
    end

    it 'sends a 404 if a user does not exist' do
      head :show, { email: 'fake@notanemail.com' }

      expect(response).to be_not_found
      expect(response.body).to be_empty
    end
  end

  context '#create' do
    it 'authenticates a user' do
      user = build(
        :user,
        email: 'foobar@example.com',
        password: 'password'
      )
      user.stub(valid_password?: true)
      User.stub(find_by: user)

      post :create, { email: user.email, password: user.password }

      expect(User).to have_received(:find_by).with(email: user.email)
      expect(response.body).to include user.authentication_token
    end

    it 'returns an error on invalid authentication' do
      user = build(:user, email: 'foobar@example.com', password: 'password')
      user.stub(valid_password?: false)
      User.stub(find_by: user)

      post :create, { email: user.email, password: 'wrong password' }

      expect(response).to be_forbidden
    end
  end

  context '#update' do
    it 'updates a user password' do
      user = create(:user, password: 'old_password', reset_password_token: 'foobar')

      put :update, { 
        password: 'new_password', 
        password_confirmation: 'new_password',
        reset_password_token: user.reset_password_token 
      }

      expect(response.body['user']['password']).to eq 'new_password'
    end
    it 'returns an error if the password confirmation does not match' do
      user = create(:user, password: 'old_password', reset_password_token: 'foobar')

      put :update, {
        password: 'new_password',
        password_confirmation: 'non_matching_password',
        reset_password_token: user.reset_password_token
      }

      expect(response).to be_unprocessable_entity
    end
    it 'returns a 404 if the user does not exist'
      user = create(:user, password: 'old_password', reset_password_token: 'foobar')

      put :update, {
        password: 'new_password',
        password_confirmation: 'new_password',
        reset_password_token: 'invalid_reset_token'
      }

      expect(response).to be_not_found
    end
  end

  context '#send_reset_email' do
    it 'sends a password reset email' do
      user = create(:user, email: 'foobar@example.com')

      patch :send_reset_email, { email: user.email }

      expect(response).to be_request_ok
      expect(response.body).to be_empty
    end
    it 'sends a 404 if the user does not exist' do
      patch :send_reset_email, { email: 'foobar@example.com' }

      expect(response).to be_not_found
    end
  end

end
