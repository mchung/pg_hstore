# Adds the :hstore type to PostgreSQLColumn
#
# Favors an approach to overriding that utilizes modules, instead of :alias.
module ActiveRecord
  module ConnectionAdapters
    class PostgreSQLColumn
      
      module SimplifiedTypeWithHStore
        def simplified_type(field_type)
          case field_type
            when /^hstore$/
              :hstore
            else
              super
          end
        end
      end

      include SimplifiedTypeWithHStore
    end
  end
end
