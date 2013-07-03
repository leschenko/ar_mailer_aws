require 'spec_helper'

describe ArMailerAWS do

  it 'setup yields ArMailerAWS' do
    ArMailerAWS.setup do |config|
      config.should == ArMailerAWS
    end
  end

  describe '#run', focus: true do
    before do
      @sender = ArMailerAWS::Sender.new(delay: 1)
      ArMailerAWS::Sender.stub(:new).and_return(@sender)
    end

    it 'run sender' do
      @sender.should_receive(:send_batch).twice
      begin
        Timeout::timeout(2) do
          ArMailerAWS.run({})
        end
      rescue Timeout::Error
      end
    end

  end
end
