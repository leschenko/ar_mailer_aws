# ArMailerAWS

Daemon for sending butches of emails via Amazon Simple Email Service (Amazon SES) using ActiveRecord for storing messages



## Installation

Add this line to your application's Gemfile:

    gem 'ar_mailer_aws'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ar_mailer_aws

Run generator:

    $ rails g ar_mailer_aws BatchEmail

Run migrations:

    $ rake db:migrate

## Usage

Edit config/initializer/ar_mailer_aws.rb and uncomment below line to use ar_mailer as default delivery method:

  ActionMailer::Base.delivery_method = :ar_mailer_ses

Or if you need to, you can set each mailer class delivery method individually:

  class MyMailer < ActionMailer::Base
    self.delivery_method = :ar_mailer_ses
  end

Run delivery daemon:

    $ bundle exec ar_mailer_aws start


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
