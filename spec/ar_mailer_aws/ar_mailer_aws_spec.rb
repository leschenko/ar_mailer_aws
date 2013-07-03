require 'spec_helper'

describe ArMailerAWS do
  
  it 'setup yields ArMailerAWS', focus: true do
    ArMailerAWS.setup do |config|
      config.should == ArMailerAWS
    end
  end

end
