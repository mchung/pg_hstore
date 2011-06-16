# require 'rails/generators'
# require 'rails/generators/migration'

module PgHstore
  class Railtie < Rails::Railtie
    # Load with Rails
    initializer 'active_record.postgresql.hstore' do
      run_hstore_initializer
    end

    # Load with Rake
    rake_tasks do
      run_hstore_initializer
    end
  end
end
