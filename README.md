# ArMailerAWS

[![Build Status](https://travis-ci.org/leschenko/ar_mailer_aws.png?branch=master)](https://travis-ci.org/leschenko/ar_mailer_aws)
[![Dependency Status](https://gemnasium.com/leschenko/ar_mailer_aws.png)](https://gemnasium.com/leschenko/ar_mailer_aws)

Daemon for sending butches of emails via Amazon Simple Email Service (Amazon SES), SMTP or Mandrill using ActiveRecord for storing messages.
ArMailerAWS handles daily quotas, maximum number of emails send per second (max send rate),
batch email sending, expiring undelivered emails.

## Installation

Add this line to your application's Gemfile:

    gem 'ar_mailer_aws'

And then execute:

    $ bundle

Run generator:

    $ rails g ar_mailer_aws BatchEmail

Run migrations:

    $ rake db:migrate

Or install it yourself as:

    $ gem install ar_mailer_aws

## Usage

To use `ar_mailer_aws` as default delivery method edit `config/initializer/ar_mailer_aws.rb` and uncomment below line:

```ruby
  ActionMailer::Base.delivery_method = :ar_mailer_aws
```

If you need `ar_mailer_aws` delivery method in particular mailer:

```ruby
  class MyMailer < ActionMailer::Base
    self.delivery_method = :ar_mailer_aws
  end
```

Run delivery daemon:

    $ bundle exec ar_mailer_aws start

List available options:

    $ bundle exec ar_mailer_aws --help

There are some configuration, see your generated `config/initializer/ar_mailer_aws.rb`

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
