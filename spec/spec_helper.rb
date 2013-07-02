require 'active_record'
require 'active_support/core_ext'
require 'ar_mailer_aws'
require 'forgery'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  create_table :batch_emails do |t|
    t.string :from
    t.string :to
    t.text :mail, limit: 16777215
    t.datetime :last_send_attempt_at
    t.datetime :created_at
  end
end

#ActiveRecord::Base.logger = Logger.new(STDERR)

ArMailerAWS.setup do |config|
  config.logger = Logger.new(STDERR)
end

class BatchEmail < ActiveRecord::Base

end

class CustomEmailClass

end