require 'spec_helper'

describe ArMailerAWS::Mailer do

  it 'initializer email_class option' do
    mailer = ArMailerAWS::Mailer.new(email_class: CustomEmailClass)
    mailer.email_class.name.should == 'CustomEmailClass'
  end

  context 'delivering' do
    before do
      @mail = double('Mail')
      @mail.stub(:return_path).and_return('from@example.com')
      @mail.stub(:destinations).and_return(['to@example.com'])
      @mail.stub(:encoded).and_return('email content')
      @mailer = ArMailerAWS::Mailer.new
    end

    it '#check_params' do
      params = @mailer.send(:check_params, @mail)
      params[0].should == 'from@example.com'
      params[1].should == ['to@example.com']
      params[2].should == 'email content'
    end

    it 'store emails into db on deliver!' do
      expect {
        @mailer.deliver!(@mail)
      }.to change { @mailer.email_class.count }.by(1)
    end
  end
end