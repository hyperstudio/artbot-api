require 'spec_helper'

describe TokensController do
  context '#create' do
    it 'authenticates a user' do
      user = build(
        :user,
        email: 'foobar@example.com',
        password: 'password',
        authentication_token: 'bleep'
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
end
