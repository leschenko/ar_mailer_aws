require 'rails/generators'
require 'rails/generators/migration'

class ArMailerAwsGenerator < Rails::Generators::NamedBase
  include Rails::Generators::Migration

  source_root File.expand_path('../templates', __FILE__)

  def create_ar_mailer_files
    self.class.check_class_collision class_name
    template('ar_mailer_aws.rb', 'config/initializers/ar_mailer_aws.rb')
    template('model.rb', File.join('app/models', class_path, "#{file_name}.rb"))
    migration_template 'migration.rb', "db/migrate/create_#{file_path.gsub(/\//, '_').pluralize}.rb"
  end
  
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime('%Y%m%d%H%M%S')
    else
     '%.3d' % (current_migration_number(dirname) + 1)
   end
  end
  
  def self.banner
    'Usage: rails ar_mailer_aws EmailModelName (default: BatchEmail)'
  end  
end
