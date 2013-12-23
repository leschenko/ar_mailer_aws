module ArMailerAWS
  module Clients
    class AmazonSES < Base

      def initialize(options={})
        super
        if ArMailerAWS.ses_options && !ArMailerAWS.client_config[:amazon_ses]
          ActiveSupport::Deprecation.warn('`ArMailerAWS.ses_options` is deprecated, use `ArMailerAWS.client_config[:amazon_ses]` instead')
          ArMailerAWS.client_config[:amazon_ses] = ArMailerAWS.ses_options
        end
        @client = AWS::SimpleEmailService.new ArMailerAWS.client_config[:amazon_ses]
      end

      def send_emails(emails)
        emails.each do |email|
          return if exceed_quota?
          begin
            check_rate
            send_email(email)
          rescue => e
            handle_error(e)
          end
        end
      end

      def send_email(email)
        log "send email to #{email.to}"
        @client.send_raw_email email.mail, from: email.from, to: email.to
        email.destroy
        @sent_count += 1
      end

    end
  end
end
