require 'spec_helper'

def create_email(options={})
  BatchEmail.create!({from: 'from@example.com', to: 'to@example.com', mail: 'email content'}.update(options))
end

describe ArMailerAws::Sender do

  it 'convert Hash options to OpenStruct' do
    sender = ArMailerAws::Sender.new({})
    sender.options.class.name.should == 'OpenStruct'
  end

  it 'get default emails model' do
    ArMailerAws::Sender.new.model.name.should == 'BatchEmail'
  end

  it 'supply ses options to AWS::SimpleEmailService initializer' do
    ArMailerAws.ses_options = {a: 1}
    AWS::SimpleEmailService.should_receive(:new).with({a: 1})
    ArMailerAws::Sender.new
  end

  context 'sending' do
    before do
      BatchEmail.delete_all
    end

    it 'find batch_size emails' do
      5.times { create_email }
      @sender = ArMailerAws::Sender.new(batch_size: 3)
      @sender.find_emails.should have(3).emails
    end

    it 'find batch_size emails' do
      2.times { create_email }
      2.times { create_email(last_send_attempt_at: Time.now - 100) }
      @sender = ArMailerAws::Sender.new(batch_size: 3)
      @sender.find_emails.should have(2).emails
    end
  end

end
