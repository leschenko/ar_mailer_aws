module ArMailerAWS
  class OptionsParser

    def self.parse_options(all_args)
      start_i = all_args.index('--').try(:succ) || 0
      args = all_args[start_i..-1]
      new(args).parse
    end

    def initialize(args)
      @args = args
      @options = OpenStruct.new
    end

    def parse
      option_parser.parse!(@args)
      @options
    end

    def option_parser
      OptionParser.new do |opts|
        @options.batch_size = 100
        @options.delay = 180
        @options.quota = 10_000
        @options.rate = 5
        @options.max_age = 3600 * 24 * 7

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
                "Default: #{@options.batch_size}", Integer) do |batch_size|
          @options.batch_size = batch_size
        end

        opts.on('-d', '--delay DELAY', 'Delay between checks for new mail in the database',
                "Default: #{@options.delay}", Integer) do |delay|
          @options.delay = delay
        end

        opts.on('-q', '--quota QUOTA', 'Daily quota for sending emails', "Default: #{@options.quota}", Integer) do |quota|
          @options.quota = quota
        end

        opts.on('-r', '--rate RATE', 'Maximum number of emails send per second',
                "Default: #{@options.rate}", Integer) do |rate|
          @options.rate = rate
        end

        opts.on('-m', '--max-age MAX_AGE',
                'Maxmimum age for an email. After this',
                'it will be removed from the queue.',
                'Set to 0 to disable queue cleanup.',
                "Default: #{@options.max_age} seconds", Integer) do |max_age|
          @options.max_age = max_age
        end

        opts.on('-p', '--pid-dir DIRECTORY', 'Directory for storing pid file',
                'Default: Stored in current directory (named `ar_mailer_aws.pid`)') do |pid_dir|
          @options.pid_dir = pid_dir
        end

        opts.on('--app-name APP_NAME', 'Name for the daemon app',
                'Default: ar_mailer_aws') do |app_name|
          @options.app_name = app_name
        end

        opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
          @options.verbose = v
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end
    end
  end
end