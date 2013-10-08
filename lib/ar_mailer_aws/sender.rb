module ArMailerAWS
  class Sender
    attr_reader :options, :model, :ses

    def initialize(options={})
      @options = options.is_a?(Hash) ? OpenStruct.new(options) : options
      @model = ArMailerAWS.email_class.constantize
      @ses = AWS::SimpleEmailService.new ArMailerAWS.ses_options
      @day = Date.today
      @sent_count = 0
    end

    def send_batch
      cleanup
      emails = find_emails
      log "found #{emails.length} emails to deliver"
      send_emails(emails) unless emails.empty?
    end

    def send_emails(emails)
      sent_per_second = 0
      emails.each do |email|
        if exceed_quota?
          log "exceed daily quota in #{@quota}, sent by mailer #{@sent_count}, other #{@sent_last_24_hours}"
          return
        end
        begin
          if sent_per_second == options.rate
            sleep 1
            sent_per_second = 0
          else
            sent_per_second += 1
          end
          log "send email to #{email.to}"
          @ses.send_raw_email email.mail, from: email.from, to: email.to
          email.destroy
          @sent_count += 1
        rescue => e
          log "ERROR sending email #{email.id} - #{email.inspect}: #{e.message}\n   #{e.backtrace.join("\n   ")}", :error
          ArMailerAWS.error_proc.call(email, e) if ArMailerAWS.error_proc
          email.update_column(:last_send_attempt_at, Time.now)
        end
      end
    end

    def exceed_quota?
      if @day == Date.today
        options.quota <= @sent_count + sent_last_24_hours
      else
        @sent_count = 0
        @sent_last_24_hours = nil
        false
      end
    end

    def sent_last_24_hours
      @sent_last_24_hours ||= begin
        count = @ses.quotas[:sent_last_24_hours]
        log "#{count} emails sent last 24 hours"
        count
      end
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

    def log(msg, level=:info)
      formatted_msg = "[#{Time.now}] ar_mailer_aws: #{msg}"
      puts formatted_msg if options.verbose
      if logger
        logger.send(level, msg)
      elsif options.verbose && defined? Rails
        Rails.logger.send(level, formatted_msg)
      end
    end

    def logger
      ArMailerAWS.logger
    end
  end
end
