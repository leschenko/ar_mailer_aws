module ArMailerAWS
  module Clients

    autoload :SMTP, 'ar_mailer_aws/clients/smtp'
    autoload :AmazonSES, 'ar_mailer_aws/clients/amazon_ses'
    autoload :Mandrill, 'ar_mailer_aws/clients/mandrill'

    class Base
      attr_reader :options, :model, :service

      def initialize(options={})
        @options = options.is_a?(Hash) ? OpenStruct.new(options) : options
        @model = ArMailerAWS.email_class.constantize
        @day = Date.today
        @sent_count = 0
        @sent_per_second = 0
      end

      def send_batch
        cleanup
        emails = find_emails
        log "found #{emails.length} emails to deliver"
        send_emails(emails) unless emails.empty?
      end

      def send_emails(emails)
        raise NotImplementedError
      end

      def find_emails
        @model.where('last_send_attempt_at IS NULL OR last_send_attempt_at < ?', Time.now - 300).limit(options.batch_size)
      end

      def cleanup
        return if options.max_age.to_i.zero?
        timeout = Time.now - options.max_age
        emails = @model.destroy_all(['last_send_attempt_at IS NOT NULL AND created_at < ?', timeout])

        log "expired #{emails.length} emails"
      end

      private

      def check_rate
        if @sent_per_second == options.rate
          sleep 1
          @sent_per_second = 0
        else
          @sent_per_second += 1
        end
      end

      def handle_error(e, email)
        log "ERROR sending email #{email.id} - #{email.inspect}: #{e.message}\n   #{e.backtrace.join("\n   ")}", :error
        ArMailerAWS.error_proc.call(email, e) if ArMailerAWS.error_proc
        email.update_column(:last_send_attempt_at, Time.now)
      end

      def exceed_quota?
        if @day == Date.today
          is_exceed_quota = options.quota <= @sent_count + sent_last_24_hours
          log("exceed daily quota in #{@quota}, sent #{@sent_count} (total #{@sent_last_24_hours})") if is_exceed_quota
          is_exceed_quota
        else
          @sent_count = 0
          @sent_last_24_hours = nil
          false
        end
      end

      def sent_last_24_hours
        0
      end

      def log(msg, level=:info)
        formatted_msg = "[#{Time.now}] batch_mailer: #{msg}"
        puts formatted_msg if options.verbose
        if logger
          logger.send(level, msg)
        elsif options.verbose && Object.const_defined?('Rails')
          Rails.logger.send(level, formatted_msg)
        end
      end

      def logger
        ArMailerAWS.logger
      end

      def client_log(msg, level=:info)
        formatted_msg = "[#{Time.now}] batch_mailer_client: #{msg}"
        puts formatted_msg if options.verbose
        if client_logger
          client_logger.send(level, msg)
        elsif options.verbose && Object.const_defined?('Rails')
          Rails.logger.send(level, formatted_msg)
        end
      end

      def client_logger
        ArMailerAWS.client_logger
      end
    end
  end
end
