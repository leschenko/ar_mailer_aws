require 'net/smtp'

module ArMailerAWS
  module Clients
    class SMTP < Base

      def send_emails(emails)
        @service = Net::SMTP.new(settings[:address], settings[:port])
        @service.enable_starttls_auto if settings[:enable_starttls_auto]
        @service.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication]) do |smtp|
          emails.each do |email|
            begin
              break if exceed_quota?
              smtp.send_message email.mail, email.from, email.to
            rescue => e
              handle_error(e, email)
            end
          end
        end
      end

      def send_email(email)
        log "send email to #{email.to}"
        @service.send_message email.mail, email.from, email.to
        email.destroy
        @sent_count += 1
      end

    end
  end
end
