require 'spec_helper'

def create_email(options={})
  BatchEmail.create!({from: 'from@example.com', to: 'to@example.com', mail: 'email content'}.update(options))
end

describe ArMailerAWS::Clients::AmazonSES do

  it 'supply ses options to AWS::SimpleEmailService initializer' do
    ArMailerAWS.client_config = {amazon_ses: {a: 1}}
    AWS::SimpleEmailService.should_receive(:new).with({a: 1})
    ArMailerAWS::Clients::AmazonSES.new
  end

  context 'sending' do
    before do
      BatchEmail.delete_all
    end

    describe '#send_emails' do
      before do
        @client = ArMailerAWS::Clients::AmazonSES.new(quota: 100)
        @client.service.stub(:send_raw_email)
        @client.service.stub(:quotas).and_return({sent_last_24_hours: 0})
      end

      context 'success' do
        it 'send email via ses' do
          2.times { create_email }
          @client.service.should_receive(:send_raw_email).twice
          @client.send_emails(@client.model.all)
        end

        it 'remove sent emails' do
          2.times { create_email }
          expect {
            @client.send_emails(@client.model.all)
          }.to change { @client.model.count }.from(2).to(0)
        end
      end

      context 'error' do
        it 'call error_proc' do
          email = create_email
          exception = StandardError.new
          ArMailerAWS.error_proc = proc {}
          ArMailerAWS.error_proc.should_receive(:call).with(email, exception)
          @client.service.should_receive(:send_raw_email).and_raise(exception)
          @client.send_emails([email])
        end

        it 'update last_send_attempt_at column' do
          email = create_email
          exception = StandardError.new
          @client.service.should_receive(:send_raw_email).and_raise(exception)
          @client.send_emails([email])
          email.reload.last_send_attempt_at.should_not be_nil
        end
      end

      context 'rate' do
        it 'call not more the rate times per second' do
          5.times { create_email }
          @client.options.rate = 2
          @client.service.should_receive(:send_raw_email).twice
          begin
            Timeout::timeout(1) do
              @client.send_emails(@client.model.all)
            end
          rescue Timeout::Error
          end
        end
      end

      context 'quota' do
        it 'not exceed quota' do
          10.times { create_email }
          @client.options.quota = 5
          expect {
            @client.send_emails(@client.model.all)
          }.to change { @client.model.count }.by(-5)
        end

        it 'consider sent_last_24_hours from ses' do
          10.times { create_email }
          @client.service.stub(:quotas).and_return({sent_last_24_hours: 10})
          @client.options.quota = 15
          expect {
            @client.send_emails(@client.model.all)
          }.to change { @client.model.count }.by(-5)
        end
      end
    end

  end
end
