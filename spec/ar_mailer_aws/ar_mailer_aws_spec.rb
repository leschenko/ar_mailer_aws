require 'spec_helper'

describe ArMailerAWS do

  it 'setup yields ArMailerAWS' do
    ArMailerAWS.setup do |config|
      expect(config).to eq ArMailerAWS
    end
  end

  describe '#run' do
    before do
      allow(ArMailerAWS).to receive(:client_config).and_return({amazon_ses: {}})
      @client = ArMailerAWS::Clients::AmazonSES.new(delay: 1)
      allow(ArMailerAWS::Clients::AmazonSES).to receive(:new).and_return(@client)
    end

    it 'run sender' do
      expect(@client).to receive(:send_batch).twice
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
        allow(ArMailerAWS).to receive(:client).and_return(:smtp)
        expect(ArMailerAWS.find_client_klass).to eq ArMailerAWS::Clients::SMTP
      end

      it 'resolve symbol to class 2' do
        allow(ArMailerAWS).to receive(:client).and_return(:amazon_ses)
        expect(ArMailerAWS.find_client_klass).to eq ArMailerAWS::Clients::AmazonSES
      end
    end

    context 'option as Class' do
      before do
        allow(ArMailerAWS).to receive(:client).and_return(Object)
      end

      it 'return direct value' do
        expect(ArMailerAWS.find_client_klass).to eq Object
      end
    end

    context 'resolve from client_config' do
      it 'resolve symbol to class' do
        allow(ArMailerAWS).to receive(:client_config).and_return({smtp: {}})
        expect(ArMailerAWS.find_client_klass).to eq ArMailerAWS::Clients::SMTP
      end

      it 'resolve symbol to class 2' do
        allow(ArMailerAWS).to receive(:client_config).and_return({amazon_ses: {}})
        expect(ArMailerAWS.find_client_klass).to eq ArMailerAWS::Clients::AmazonSES
      end
    end
  end

end
