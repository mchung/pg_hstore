require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

setup_rails_env

describe "SchemaDumper with HStore" do

  before(:each) do
    create_pg_hstore_test
    io = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, io)
    @schema = io.string
  end

  after(:each) do
    drop_pg_hstore_test
  end

  it "should understand how to #dump the hstore data type" do
    hstore_type = /t.hstore.*\"data\"/
    @schema.should match hstore_type
    @schema.should_not match /Unknown type 'hstore' for column 'data'/
  end

  it "should load hstore.sql in schema.rb" do
    # Escaping quotes and parens within a regular expression!
    # 
    # We want to detect the following string:
    #
    #   execute File.read("#{Rails.root}/db/hstore.sql")
    #
    # Just be glad it doesn't have to do time zone math!
    extra_hstore_sql = /execute File.read\(\"\#{Rails.root}\/db\/hstore.sql\"\)/
    @schema.should match extra_hstore_sql
  end
end