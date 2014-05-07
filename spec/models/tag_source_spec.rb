require 'spec_helper'

describe TagSource do
  it { should validate_presence_of(:name) }

  context 'tagging' do
    it { should respond_to(:owned_taggings) }
  end

  it 'has a dbpedia entity finder' do
    expect(described_class.dbpedia).to be_instance_of(described_class)
  end
end
