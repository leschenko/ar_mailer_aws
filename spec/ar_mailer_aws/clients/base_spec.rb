require 'spec_helper'

def create_email(options={})
  BatchEmail.create!({from: 'from@example.com', to: 'to@example.com', mail: 'email content'}.update(options))
end

describe ArMailerAWS::Clients::Base do

  it 'convert Hash options to OpenStruct' do
    client = ArMailerAWS::Clients::Base.new
    expect(client.options.class.name).to eq 'OpenStruct'
  end

  it 'get default emails model' do
    expect(ArMailerAWS::Clients::Base.new.model.name).to eq 'BatchEmail'
  end

  context 'sending' do
    before do
      BatchEmail.delete_all
    end

    describe '#find_emails' do
      it 'batch_size emails' do
        5.times { create_email }
        @client = ArMailerAWS::Clients::Base.new(batch_size: 3)
        expect(@client.find_emails.length).to eq 3
      end

      it 'ignore emails last_send_attempt_at < 300 seconds ago' do
        2.times { create_email }
        2.times { create_email(last_send_attempt_at: Time.now - 100) }
        @client = ArMailerAWS::Clients::Base.new(batch_size: 3)
        expect(@client.find_emails.length).to eq 2
      end
    end

    describe '#cleanup' do
      it 'do nothing if max_age zero and max_attempts zero' do
        @client = ArMailerAWS::Clients::Base.new(max_age: 0, max_attempts: 0)
        expect(@client.model).not_to receive(:where)
        @client.cleanup
      end

      it 'remove emails with last_send_attempt_at and create_at greater then max_age' do
        2.times { create_email }
        2.times { create_email(last_send_attempt_at: Time.now, created_at: Time.now - 4000) }

        @client = ArMailerAWS::Clients::Base.new(max_age: 3600)
        expect {
          @client.cleanup
        }.to change { @client.model.count }.from(4).to(2)
      end

      it 'remove emails with send_attempts_count greater then max_attempts' do
        2.times { create_email }
        2.times { create_email(send_attempts_count: 11) }

        @client = ArMailerAWS::Clients::Base.new(max_attempts: 10)
        expect { @client.cleanup }.to change { @client.model.count }.from(4).to(2)
      end
    end

    describe '#send_emails' do
      it 'raise not implemented error' do
        expect{ ArMailerAWS::Clients::Base.new.send_emails([]) }.to raise_error(NotImplementedError)
      end
    end

    describe '#send_batch' do
      before do
        @client = ArMailerAWS::Clients::Base.new
        allow(@client).to receive(:send_emails)
      end

      it 'no pending emails' do
        expect(@client).to receive(:cleanup)
        expect(@client).to receive(:find_emails).and_return([])
        expect(@client).not_to receive(:send_emails)
        @client.send_batch
      end

      it 'no pending emails' do
        expect(@client).to receive(:find_emails).and_return([create_email])
        expect(@client).to receive(:send_emails)
        @client.send_batch
      end
    end

  end
end
