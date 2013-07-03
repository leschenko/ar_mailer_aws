require 'ar_mailer_aws/version'
require 'ar_mailer_aws/sender'
require 'ar_mailer_aws/mailer'
require 'ar_mailer_aws/railtie' if defined? Rails
require 'active_support/core_ext'

module ArMailerAWS

  # ActiveRecord class for storing emails
  mattr_accessor :email_class
  @@email_class = 'BatchEmail'

  # options to AWS::SimpleEmailService initializer
  mattr_accessor :ses_options
  @@ses_options = {}

  # ar_mailer_aws logger
  mattr_accessor :logger

  # error proc called when error occurred during delivering an email
  # Example: lambda { |email, exception| ExceptionNotifier::Notifier.background_exception_notification(exception, data: {email: email.attributes}).deliver }
  mattr_accessor :error_proc

  class << self
    def setup
      yield self
    end

    def run(options)
      sender = Sender.new(options)
      loop do
        sender.send_batch
        sleep sender.options.delay
      end
    end

    def parse_options(args)
      start_i = args.index('--').try(:succ) || 0
      args = args[start_i..-1]
      options = OpenStruct.new

      OptionParser.new do |opts|
        options.batch_size = 100
        options.delay = 180
        options.quota = 10_000
        options.rate = 5
        options.max_age = 3600 * 24 * 7

        opts.banner = <<-TXT.strip_heredoc
          Usage: ar_mailer_aws <command> <options> -- <application options>

          * where <command> is one of:
            start         start an instance of the application
            stop          stop all instances of the application
            restart       stop all instances and restart them afterwards
            reload        send a SIGHUP to all instances of the application
            run           start the application and stay on top
            zap           set the application to a stopped state
            status        show status (PID) of application instances

          * where <options> may contain several of the following:

              -t, --ontop                      Stay on top (does not daemonize)
              -f, --force                      Force operation
              -n, --no_wait                    Do not wait for processes to stop

          * and where <application options> may contain several of the following:

        TXT

        opts.on('-b', '--batch-size BATCH_SIZE', 'Maximum number of emails to send per delay',
                "Default: #{options.batch_size}", Integer) do |batch_size|
          options.batch_size = batch_size
        end

        opts.on('-d', '--delay DELAY', 'Delay between checks for new mail in the database',
                "Default: #{options.delay}", Integer) do |delay|
          options.delay = delay
        end

        opts.on('-q', '--quota QUOTA', 'Daily quota for sending emails', "Default: #{options.quota}", Integer) do |quota|
          options.quota = quota
        end

        opts.on('-r', '--rate RATE', 'Maximum number of emails send per second',
                "Default: #{options.rate}", Integer) do |rate|
          options.rate = rate
        end

        opts.on('-m', '--max-age MAX_AGE',
                'Maxmimum age for an email. After this',
                'it will be removed from the queue.',
                'Set to 0 to disable queue cleanup.',
                "Default: #{options.max_age} seconds", Integer) do |max_age|
          options.max_age = max_age
        end

        opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
          options.verbose = v
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end

      end.parse!(args)

      options
    end

  end
end
