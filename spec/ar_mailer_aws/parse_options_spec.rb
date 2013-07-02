require 'spec_helper'

describe 'command line options parsing' do
  it 'return defaults if no options specified' do
    options = ArMailerAws.parse_options([])
    options.batch_size.should == 100
    options.delay.should == 180
    options.quota.should == 10_000
    options.rate.should == 5
    options.max_age.should == 3600 * 24 * 7
  end

  it 'batch_size' do
    ArMailerAws.parse_options(%w(-b 10)).batch_size.should == 10
  end

  it 'delay' do
    ArMailerAws.parse_options(%w(-d 90)).delay.should == 90
  end

  it 'quota' do
    ArMailerAws.parse_options(%w(-q 100)).quota.should == 100
  end

  it 'rate' do
    ArMailerAws.parse_options(%w(-r 7)).rate.should == 7
  end

  it 'max_age' do
    ArMailerAws.parse_options(%w(-m 300)).max_age.should == 300
  end

  it 'verbose' do
    ArMailerAws.parse_options(%w(-v)).verbose.should be_true
  end
end