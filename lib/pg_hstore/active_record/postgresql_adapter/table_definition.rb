# Add the hstore type to the TableDefinition method
#
# This allows developers to use 'hstore' as a column definition in a migration
# 
# Example:
#
# class CreateDocuments < ActiveRecord::Migration
#   def change
#     create_table :documents do |t|
#       t.hstore :data
#       t.timestamps
#     end
#   end
# end
#
#
ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::TableDefinition.class_eval do
  def hstore(*args)
    options = args.extract_options!
    column(args[0], 'hstore', options)
  end
end