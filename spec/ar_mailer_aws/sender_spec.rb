require 'spec_helper'

def create_email(options={})
  BatchEmail.create!({from: 'from@example.com', to: 'to@example.com', mail: 'email content'}.update(options))
end

describe ArMailerAWS::Sender do

  it 'convert Hash options to OpenStruct' do
    sender = ArMailerAWS::Sender.new({})
    sender.options.class.name.should == 'OpenStruct'
  end

  it 'get default emails model' do
    ArMailerAWS::Sender.new.model.name.should == 'BatchEmail'
  end

  it 'supply ses options to AWS::SimpleEmailService initializer' do
    ArMailerAWS.ses_options = {a: 1}
    AWS::SimpleEmailService.should_receive(:new).with({a: 1})
    ArMailerAWS::Sender.new
  end

  context 'sending' do
    before do
      BatchEmail.delete_all
    end

    describe '#find_emails' do
      it 'batch_size emails' do
        5.times { create_email }
        @sender = ArMailerAWS::Sender.new(batch_size: 3)
        @sender.find_emails.should have(3).emails
      end

      it 'ignore emails last_send_attempt_at < 300 seconds ago' do
        2.times { create_email }
        2.times { create_email(last_send_attempt_at: Time.now - 100) }
        @sender = ArMailerAWS::Sender.new(batch_size: 3)
        @sender.find_emails.should have(2).emails
      end
    end

    describe '#cleanup' do
      it 'do nothing if max_age == 0' do
        @sender = ArMailerAWS::Sender.new(max_age: 0)
        @sender.model.should_not_receive(:destroy_all)
        @sender.cleanup
      end

      it 'remove emails with last_send_attempt_at and create_at greater then max_age' do
        2.times { create_email }
        2.times { create_email(last_send_attempt_at: Time.now, created_at: Time.now - 4000) }

        @sender = ArMailerAWS::Sender.new(max_age: 3600)
        expect {
          @sender.cleanup
        }.to change { @sender.model.count }.from(4).to(2)
      end
    end

    describe '#send_emails' do
      before do
        @sender = ArMailerAWS::Sender.new
        @sender.ses.stub(:send_raw_email)
      end

      context 'success' do
        it 'send email via ses' do
          2.times { create_email }
          @sender.ses.should_receive(:send_raw_email).twice
          @sender.send_emails(BatchEmail.all)
        end

        it 'remove sent emails' do
          2.times { create_email }
          expect {
            @sender.send_emails(BatchEmail.all)
          }.to change { @sender.model.count }.from(2).to(0)
        end
      end

      context 'error', focus: true do
        it 'call error_proc' do
          email = create_email
          exception = StandardError.new
          ArMailerAWS.error_proc = proc {}
          ArMailerAWS.error_proc.should_receive(:call).with(email, exception)
          @sender.ses.should_receive(:send_raw_email).and_raise(exception)
          @sender.send_emails([email])
        end
      end
    end

  end

end
