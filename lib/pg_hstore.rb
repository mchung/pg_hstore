require 'pg_hstore/railties/railtie' if defined?(Rails)

def run_hstore_initializer
  # Initialize hstore after ActiveRecord has loaded
  ActiveSupport.on_load :active_record do
    # For schema dump/load compatibility
    require 'pg_hstore/active_record/postgresql_adapter'
    require 'pg_hstore/active_record/postgresql_adapter/postgresql_column'
    require 'pg_hstore/active_record/schema_dumper'
    
    # For table migrations
    require 'pg_hstore/active_record/postgresql_adapter/table_definition'

    # Include extra functionality into all AR objects!
    require 'pg_hstore/hstore_type'
    include HstoreType
  end
end