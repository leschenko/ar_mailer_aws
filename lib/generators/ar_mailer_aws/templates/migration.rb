class <%= migration_class_name.gsub(/::/, '') %> < ActiveRecord::Migration
  def change
    create_table :<%= table_name %> do |t|
      t.string :from
      t.string :to
      t.text :mail, limit: 16777215
      t.integer :send_attempts_count, default: 0
      t.datetime :last_send_attempt_at
      t.datetime :created_at
    end
  end
end
