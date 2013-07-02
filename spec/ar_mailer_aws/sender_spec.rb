require 'spec_helper'

describe ArMailerAws::Sender do

  before do
    10.times do
      BatchEmail.create!(from: Forgery::Email.address, to: Forgery::Email.address, mail: Forgery::LoremIpsum.paragraphs(rand(10)))
    end
    @sender = ArMailerAws::Sender.new(batch_size: 3)
  end

  it 'find emails' do
    @sender.find_emails.should have(3).emails
  end

end
