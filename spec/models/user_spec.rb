require 'spec_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email) }

  it { should have_many(:favorites).dependent(:destroy) }
  it { should have_many(:events).through(:favorites) }
  it { should have_many(:interests).dependent(:destroy) }

  context 'authentication_token' do
    it 'creates a token when a user is created' do
      authentication_token = 'foobar'
      Devise.stub(friendly_token: authentication_token)
      user = build(:user)

      user.save
      expect(Devise).to have_received(:friendly_token)
      expect(user.authentication_token).to eq authentication_token
    end
  end
end
