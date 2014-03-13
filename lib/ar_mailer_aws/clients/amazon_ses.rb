# too early require aws-sdk breaks mailer, need to be required by rails app
#require 'aws-sdk'

module ArMailerAWS
  module Clients
    class AmazonSES < Base

      def initialize(options={})
        super
        if ArMailerAWS.ses_options && settings.blank?
          ActiveSupport::Deprecation.warn('`ArMailerAWS.ses_options` is deprecated, use `ArMailerAWS.client_config[:amazon_ses]` instead')
          @settings = ArMailerAWS.client_config[:amazon_ses] = ArMailerAWS.ses_options
        end
        @service = AWS::SimpleEmailService.new settings
      end

      def send_emails(emails)
        emails.each do |email|
          return if exceed_quota?
          begin
            check_rate
            send_email(email)
          rescue => e
            handle_email_error(e, email)
          end
        end
      end

      def send_email(email)
        log "send email to #{email.to}"
        @service.send_raw_email email.mail, from: email.from, to: email.to
        email.destroy
        @sent_count += 1
      end

      def sent_last_24_hours
        @sent_last_24_hours ||= begin
          count = @service.quotas[:sent_last_24_hours]
          log "#{count} emails sent last 24 hours"
          count
        end
      end

    end
  end
end
