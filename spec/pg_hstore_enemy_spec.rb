require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

setup_rails_env

describe "HStore Enemy Spec" do

  before(:each) do
    ActiveRecord::Base.establish_connection(
      :adapter  => :postgresql,
      :database => "pg_hstore_test"
    )
    ActiveRecord::Schema.define :version => 0 do
      create_table :awesome_documents, :force => true do |t|
        t.hstore   :hstore_data

        # Existing types in PostgreSQL must work
        t.tsvector :tsvector_data
        t.xml      :xml_data
      end
    end
    io = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, io)
    @schema = io.string
  end

  after(:each) do
    ActiveRecord::Schema.define :version => 0 do
      drop_table :awesome_documents
    end
  end

  it "should ensure existing AR functionality" do
    hstore_type = /t.hstore.*\"hstore_data\"/
    @schema.should match hstore_type

    tsvector_type = /t.tsvector.*\"tsvector_data\"/
    @schema.should match tsvector_type

    xml_type = /t.xml.*\"xml_data\"/
    @schema.should match xml_type

    @schema.should_not match /Unknown type 'hstore' for column 'data'/
    @schema.should_not match /Unknown type 'tsvector' for column 'tsvector_data'/
    @schema.should_not match /Unknown type 'xml' for column 'xml_data'/
  end
end