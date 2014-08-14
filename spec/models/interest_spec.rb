require 'spec_helper'

describe Interest do
  include AdminOwnedTagHelpers

  it { should belong_to(:user) }
  it { should belong_to(:tag).class_name(ActsAsTaggableOn::Tag) }

  context 'admin tags are the only valid source of tags' do
    it 'should allow an admin tag to be an interest' do
      create_admin_owned_tags('allowed')
      tag = ActsAsTaggableOn::Tag.find_by(name: 'allowed')
      user = create(:user)

      interest = build(:interest, user: user, tag: tag)
      expect(interest).to be_valid
    end

    it 'should reject a non-admin tag as an interest' do
      user = create(:user)
      disallowed_tag = create(:tag)

      interest = build(:interest, user: user, tag: disallowed_tag)
      expect(interest).not_to be_valid
    end
  end
end
