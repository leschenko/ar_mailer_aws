require 'ar_mailer_aws/version'
require 'ar_mailer_aws/options_parser'
require 'ar_mailer_aws/clients/base'
require 'ar_mailer_aws/mailer'
require 'ar_mailer_aws/railtie' if defined? Rails
require 'active_support/core_ext'

module ArMailerAWS

  # ActiveRecord class for storing emails
  mattr_accessor :email_class
  @@email_class = 'BatchEmail'

  # mailer client
  mattr_accessor :client

  # available clients
  mattr_accessor :available_clients
  @@available_clients = {
      amazon_ses: 'ArMailerAWS::Clients::AmazonSES',
      smtp: 'ArMailerAWS::Clients::SMTP'
  }

  # mailer client credentials
  mattr_accessor :client_config
  @@client_config = {}

  # DEPRECATED
  # options to AWS::SimpleEmailService initializer
  mattr_accessor :ses_options

  # ar_mailer_aws logger
  mattr_accessor :logger

  # error proc called when error occurred during delivering an email
  # Example: lambda { |email, exception| ExceptionNotifier.notify_exception(exception, data: {email: email.attributes}) }
  mattr_accessor :error_proc

  class << self
    def setup
      yield self
    end

    def run(options)
      client_klass = find_client_klass
      raise("Can not find client #{client}") unless client_klass
      client_instance = client_klass.new(options)
      loop do
        client_instance.send_batch
        sleep client_instance.options.delay
      end
    end

    def find_client_klass
      if client
        if client.is_a?(Symbol)
          available_clients[client].try(:constantize)
        elsif client.is_a?(Class)
          client
        end
      else
        available_clients[client_config.keys.first].try(:constantize)
      end
    end

  end
end
