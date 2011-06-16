$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'pg'
require 'pg_hstore'
require 'pp'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.before(:all) do
  end
end

# Load ActiveRecord and the PostgreSQLAdapter manually, then run
# our initializer, just like Rails does!
def setup_rails_env
  require 'active_support/core_ext'
  require 'active_record'
  require 'active_record/schema_dumper'
  require 'active_record/connection_adapters/postgresql_adapter'
  run_hstore_initializer
end

def create_pg_hstore_test
  ActiveRecord::Base.establish_connection(
    :adapter  => :postgresql,
    :database => "pg_hstore_test"
  )
  ActiveRecord::Schema.define :version => 0 do
    create_table :documents, :force => true do |t|
      t.hstore :data
    end
  end  
  ActiveRecord::Base.logger = nil
end

def drop_pg_hstore_test
  ActiveRecord::Schema.define :version => 0 do
    drop_table :documents
  end
end
