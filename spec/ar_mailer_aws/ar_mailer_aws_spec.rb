require 'spec_helper'

describe ArMailerAWS do

  it 'setup yields ArMailerAWS' do
    ArMailerAWS.setup do |config|
      config.should == ArMailerAWS
    end
  end

  describe '#run' do
    before do
      ArMailerAWS.stub(:client_config).and_return({amazon_ses: {}})
      @client = ArMailerAWS::Clients::AmazonSES.new(delay: 1)
      ArMailerAWS::Clients::AmazonSES.stub(:new).and_return(@client)
    end

    it 'run sender' do
      @client.should_receive(:send_batch).twice
      begin
        Timeout::timeout(1.5) do
          ArMailerAWS.run({})
        end
      rescue Timeout::Error
      end
    end
  end

  describe '#find_client_klass' do
    context 'option as Symbol' do
      it 'resolve symbol to class' do
        ArMailerAWS.stub(:client).and_return(:smtp)
        ArMailerAWS.find_client_klass.should == ArMailerAWS::Clients::SMTP
      end

      it 'resolve symbol to class 2' do
        ArMailerAWS.stub(:client).and_return(:amazon_ses)
        ArMailerAWS.find_client_klass.should == ArMailerAWS::Clients::AmazonSES
      end
    end

    context 'option as Class' do
      before do
        ArMailerAWS.stub(:client).and_return(Object)
      end

      it 'return direct value' do
        ArMailerAWS.find_client_klass.should == Object
      end
    end

    context 'resolve from client_config' do
      it 'resolve symbol to class' do
        ArMailerAWS.stub(:client_config).and_return({smtp: {}})
        ArMailerAWS.find_client_klass.should == ArMailerAWS::Clients::SMTP
      end

      it 'resolve symbol to class 2' do
        ArMailerAWS.stub(:client_config).and_return({amazon_ses: {}})
        ArMailerAWS.find_client_klass.should == ArMailerAWS::Clients::AmazonSES
      end
    end
  end

end
