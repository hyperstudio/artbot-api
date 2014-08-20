require 'spec_helper'

describe TagContext do

  it 'has a default context' do
    expect(described_class.default).to be_instance_of(described_class)
  end

  it 'should invalidate bad names' do
    bad_class_name = 'CAPITALIZED WHITESPACE SINGULAR NAME'
    
    errors = described_class.create(name: bad_class_name).errors

    expect(errors.messages[:name]).to include("must be lowercase",
                                              "must be pluralized",
                                              "can't have whitespace")
  end

end
