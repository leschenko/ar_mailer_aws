require 'spec_helper'

describe 'command line options parsing' do
  it 'return defaults if no options specified' do
    options = ArMailerAWS.parse_options([])
    options.batch_size.should == 100
    options.delay.should == 180
    options.quota.should == 10_000
    options.rate.should == 5
    options.max_age.should == 3600 * 24 * 7
  end

  it 'batch_size' do
    ArMailerAWS.parse_options(%w(-b 10)).batch_size.should == 10
  end

  it 'delay' do
    ArMailerAWS.parse_options(%w(-d 90)).delay.should == 90
  end

  it 'quota' do
    ArMailerAWS.parse_options(%w(-q 100)).quota.should == 100
  end

  it 'rate' do
    ArMailerAWS.parse_options(%w(-r 7)).rate.should == 7
  end

  it 'max_age' do
    ArMailerAWS.parse_options(%w(-m 300)).max_age.should == 300
  end

  it 'verbose' do
    ArMailerAWS.parse_options(%w(-v)).verbose.should be_true
  end

  it 'pid_dir' do
    ArMailerAWS.parse_options(%w(-p tmp/pids)).pid_dir.should == 'tmp/pids'
  end
end