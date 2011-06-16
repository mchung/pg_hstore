# Adds the :hstore type to PostgreSQLAdapter
#
#
require 'active_record/connection_adapters/postgresql_adapter'

ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES[:hstore] = { :name => "hstore" }
