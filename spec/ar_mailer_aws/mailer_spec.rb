require 'spec_helper'

describe ArMailerAWS::Mailer do

  it 'initializer email_class option' do
    mailer = ArMailerAWS::Mailer.new(email_class: CustomEmailClass)
    expect(mailer.email_class.name).to eq 'CustomEmailClass'
  end

  context 'delivering' do
    before do
      @mail = double('Mail')
      allow(@mail).to receive(:return_path).and_return('from@example.com')
      allow(@mail).to receive(:destinations).and_return(['to@example.com'])
      allow(@mail).to receive(:encoded).and_return('email content')
      @mailer = ArMailerAWS::Mailer.new
    end

    it '#check_params' do
      params = @mailer.send(:check_params, @mail)
      expect(params[0]).to eq 'from@example.com'
      expect(params[1]).to eq ['to@example.com']
      expect(params[2]).to eq 'email content'
    end

    it 'store emails into db on deliver!' do
      expect {
        @mailer.deliver!(@mail)
      }.to change { @mailer.email_class.count }.by(1)
    end
  end
end