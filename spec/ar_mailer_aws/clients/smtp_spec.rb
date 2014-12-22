require 'spec_helper'

describe ArMailerAWS::Clients::SMTP do

  describe '#send_emails' do
    before do
      allow(ArMailerAWS).to receive(:client_config).and_return({smtp: {
          address: 'smtp.example.com',
          port: 587,
          domain: 'example.com',
          authentication: 'plain',
          enable_starttls_auto: true,
          user_name: 'test@example.com',
          password: '123456'
      }})
      @client = ArMailerAWS::Clients::SMTP.new
    end

    it 'start smtp session' do
      session = Net::SMTP.new('smtp.example.com', 587)
      expect(Net::SMTP).to receive(:new).with('smtp.example.com', 587).and_return(session)
      expect(session).to receive(:start).with('example.com', 'test@example.com', '123456', 'plain')
      @client.send_emails([])
    end

    it 'send emails' do
      session = double('session').as_null_object
      email = double('email', id: 1, mail: 'mail', from: 'from', to: 'to')

      allow(Net::SMTP).to receive(:new).and_return(session)
      allow(session).to receive(:start).and_yield(session)
      expect(session).to receive(:send_message).with('mail', 'from', 'to')
      expect(email).to receive(:destroy)
      @client.send_emails([email])
    end
  end

end