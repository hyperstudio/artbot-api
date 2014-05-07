require 'spec_helper'

describe TagSource do
  it { should validate_presence_of(:name) }

  context 'tagging' do
    it { should respond_to(:owned_taggings) }
  end
end
