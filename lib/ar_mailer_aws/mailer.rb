module ArMailerAws
  class Mailer

    attr_accessor :email_class

    def initialize(options)
      self.email_class = options[:email_class] || ArMailerAws.email_class.constantize
    end

    def deliver!(mail)
      envelope_from, destinations, message = check_params(mail)

      destinations.each do |destination|
        self.email_class.create! mail: message, to: destination, from: envelope_from
      end
    end

    private

    def check_params(mail)
      envelope_from = mail.return_path || mail.sender || mail.from_addrs.first
      if envelope_from.blank?
        raise ArgumentError.new('A sender (Return-Path, Sender or From) required to send a message')
      end

      destinations ||= mail.destinations if mail.respond_to?(:destinations) && mail.destinations
      if destinations.blank?
        raise ArgumentError.new('At least one recipient (To, Cc or Bcc) is required to send a message')
      end

      message ||= mail.encoded if mail.respond_to?(:encoded)
      if message.blank?
        raise ArgumentError.new('A encoded content is required to send a message')
      end

      [envelope_from, destinations, message]
    end

  end
end
