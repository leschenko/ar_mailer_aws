require 'spec_helper'

describe ArMailerAWS::OptionsParser do

  it 'return defaults if no options specified' do
    options = ArMailerAWS::OptionsParser.parse_options([])
    expect(options.batch_size).to eq 100
    expect(options.delay).to eq 180
    expect(options.quota).to eq 10_000
    expect(options.rate).to eq 5
    expect(options.max_age).to eq 3600 * 24 * 7
    expect(options.max_attempts).to eq 5
  end

  it 'batch_size' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(-b 10)).batch_size).to eq 10
  end

  it 'delay' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(-d 90)).delay).to eq 90
  end

  it 'quota' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(-q 100)).quota).to eq 100
  end

  it 'rate' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(-r 7)).rate).to eq 7
  end

  it 'max_age' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(-m 300)).max_age).to eq 300
  end

  it 'max_attempts' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(-a 10)).max_attempts).to eq 10
  end

  it 'verbose' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(-v)).verbose).to be_truthy
  end

  it 'pid_dir' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(-p tmp/pids)).pid_dir).to eq 'tmp/pids'
  end

  it 'app_name' do
    expect(ArMailerAWS::OptionsParser.parse_options(%w(--app-name my_daemon)).app_name).to eq 'my_daemon'
  end

end