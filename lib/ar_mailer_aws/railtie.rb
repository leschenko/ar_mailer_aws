module ArMailerAws
  class Railtie < Rails::Railtie
    initializer 'ar_mailer_aws' do

      ActiveSupport.on_load :action_mailer do
        add_delivery_method :ar_amazon_ses, ArMailerAws::Mailer
      end

    end
  end
end