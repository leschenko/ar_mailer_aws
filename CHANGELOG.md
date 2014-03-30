### 0.1.0

* backwards incompatible changes
  * added `send_attempts_count` column
  * New configuration syntax:
    ```ruby
      # Your system wide Amazon config
      AWS.config(
          :access_key_id => 'YOUR_ACCESS_KEY_ID',
          :secret_access_key => 'YOUR_SECRET_ACCESS_KEY'
      )

      ArMailerAWS.setup do |config|
        # Current delivery method
        config.client = :amazon_ses

        # Delivery method client log i.e. smtp, amazon, mandrill
        # config.client_logger = Logger.new('path/to/log/file')

        # Configure your delivery method client
        config.client_config = {
            # Amazon SES config, system wide config will be used if not defined
            # amazon_ses: {
            #     access_key_id: 'YOUR_ACCESS_KEY_ID',
            #     secret_access_key: 'YOUR_SECRET_ACCESS_KEY',
            #     log_level: :debug
            #     #region: 'eu-west-1',
            # },

            # Mandrill config
            # mandrill: {
            #     key: 'YOUR_MANDRILL_KEY'
            # },

            # Your smtp config, just like rails `smtp_settings`
            # smtp: Rails.application.config.action_mailer.smtp_settings
        }

        # `ar_mailer_aws` logger i.e. mailer daemon
        #config.logger = Logger.new('path/to/log/file')

        # Error notification handler
        #config.error_proc = lambda do |email, exception|
        #  ExceptionNotifier.notify_exception(exception, data: {email: email.attributes})
        #end

        # batch email class
        # email_class = 'BatchEmail'
      end
    ```