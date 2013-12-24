require 'net/smtp'

module ArMailerAWS
  module Clients
    class SMTP < Base

      def send_emails(emails)
        session = Net::SMTP.new(settings[:address], settings[:port])
        session.enable_starttls_auto if settings[:enable_starttls_auto]
        begin
          session.start(settings[:domain], settings[:user_name], settings[:password], settings[:authentication]) do |smtp|
            emails.each do |email|
              begin
                break if exceed_quota?
                send_email(smtp, email)
              rescue => e
                handle_email_error(e, email)
              end
            end
          end
        rescue => e
          log "ERROR in SMTP session: #{e.message}\n   #{e.backtrace.join("\n   ")}", :error
          ArMailerAWS.error_proc.call(email, e) if ArMailerAWS.error_proc
        end
      end

      def send_email(smtp, email)
        log "send email to #{email.to}"
        log smtp.send_message(email.mail, email.from, email.to)
        email.destroy
        @sent_count += 1
      end

    end
  end
end
