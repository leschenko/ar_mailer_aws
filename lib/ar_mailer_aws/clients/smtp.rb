module ArMailerAWS
  module Clients
    class SMTP < Base

      def initialize(options={})
        super
        @service = ''
      end

      #def send_emails(emails)
      #  emails.each do |email|
      #    return if exceed_quota?
      #    begin
      #      check_rate
      #      send_email(email)
      #    rescue => e
      #      handle_error(e, email)
      #    end
      #  end
      #end
      #
      #def send_email(email)
      #  log "send email to #{email.to}"
      #  @service.send_raw_email email.mail, from: email.from, to: email.to
      #  email.destroy
      #  @sent_count += 1
      #end

    end
  end
end
