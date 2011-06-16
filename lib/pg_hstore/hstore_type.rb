require 'pg_hstore/hstore_class_methods'
require 'pg_hstore/hstore_instance_methods'

module HstoreType
  extend ActiveSupport::Concern

  # included do
  #   scope :foo, :conditions => { :created_at => nil }
  # end

  module ClassMethods
    def execute_sql(array)
      sql = sanitize_sql_array(array)
      self.connection.execute(sql)
    end

    def hstore(hstore_attr)
      HstoreClassMethods.new(self, hstore_attr)
    end

    # Build up a bind string for SQL. Ensures the separator is not 
    # appended to the last bound string.
    #
    # Examples
    #   For ("?", 5) will generate: ?,?,?,?,?
    #   For ("(?=>?), 2, "||") will generate (?=>?) || (?=>?)
    #
    def build_bind_sql_with(count, bind, sep = ", ")
      bind_str = "#{bind}#{sep}"
      "#{bind_str * (count-1)} #{bind}"
    end
  end

  module InstanceMethods
    def hstore(hstore_attr)
      hstore_attr = hstore_attr.to_s unless hstore_attr.kind_of? String
      # I'm an ActiveRecord object, short and stout...
      HstoreInstanceMethods.new(self, hstore_attr)
    end
  end
end
