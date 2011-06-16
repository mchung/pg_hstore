# Adds a statement to SchemaDumper that installs HStore. We do this to 
# ensure the db:schema:dump and db:schema:load rake tasks know how to work 
# with the HStore type.
#
# This is required because the database is dropped and recreated each time
# the 'rake test:units' is run.
module ActiveRecord
  class SchemaDumper
    alias :original_header :header
    
    def header(stream)
      original_header(stream) 
      stream.puts <<HSTORE_HEADER
  # Install HStore functions and types
  execute File.read("\#{Rails.root}/db/hstore.sql")

HSTORE_HEADER
    end
  end
end
