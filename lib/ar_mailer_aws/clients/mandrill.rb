require 'mandrill'
require 'mandrill/api'
require 'mail'

module ArMailerAWS
  module Clients
    class Mandrill < Base

      REJECT_HEADERS = ['From', 'To', 'Subject']

      def initialize(options={})
        super
        raise('Missing Mandrill api key') unless  ArMailerAWS.client_config[:mandrill].try(:fetch, :key)
        @service = ::Mandrill::API.new ArMailerAWS.client_config[:mandrill][:key]
      end

      def send_emails(emails)
        emails.each do |email|
          return if exceed_quota?
          begin
            check_rate
            send_email(email)
          rescue => e
            handle_error(e, email)
          end
        end
      end

      def send_email(email)
        log "send email to #{email.to}"
        email_json_hash = email_json(email)
        client_log email_json_hash, :debug
        resp = @service.messages.send email_json_hash
        client_log resp, :debug
        email.destroy
        @sent_count += 1
      end

      def email_json(email)
        mail = Mail.new(email.mail)
        headers = mail.header.reject{|h| REJECT_HEADERS.include?(h.name) }.map { |h| [h.name, h.value] }.to_hash
        {
            'subject' => mail.subject.to_s.force_encoding('UTF-8'),
            'html' => mail.body.to_s.force_encoding('UTF-8'),
            'headers' => headers,
            'from_email' => email.from,
            'track_opens' => false,
            'track_clicks' => false,
            'to' => [{'email' => email.to, 'type' => 'to'}]
        }
      end
    end
  end
end
