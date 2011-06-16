#
#
#
class HstoreInstanceMethods
 
  # TODO: Resolve efficiency issues. In theory, 
  
  # TODO Security audit. Are public arguments properly escaped to prevent SQL
  # injection attacks?
  #
  # TODO Invariant audit. What happens when key/maps are invalid?
  #
  # TODO Efficiency audit. Since the he record already has the data, why issue
  # anther query to extract? Shouldn't we resolve to parsing instead?
  
  attr_accessor :table_name, :ar_klazz, :ar_instance, :hstore_column

  # The HstoreColumn references an ActiveRecord object and the name of the
  # hstore column.
  #
  def initialize(ar_instance, hstore_column)
    self.ar_instance = ar_instance
    self.ar_klazz = self.ar_instance.class
    self.table_name = self.ar_klazz.table_name
    self.hstore_column = hstore_column
  end

  # Returns all the data in the hstore column as a Hash.
  #
  # 
  def all
    sql = <<-SQL
SELECT (each(#{hstore_column})).key, (each(#{hstore_column})).value
FROM #{table_name}
WHERE id = #{ar_instance.id}
SQL
    ({}).tap do |map|
      hstore = ar_klazz.execute_sql(sql)
      hstore.each do |row|
        row.each do |k, v|
          # The value +k+ can be one of three values: a regular attribute
          # the hstore reference to the key, and the hstore reference to the
          # value.  We only care about the hstore references.
          #
          # When
          #   +k+ is equal to "value"
          # Then we've encountered the hstore reference to the value.
          # And when
          #   +k+ is equal to "key"
          # Then we've encountered the hstore reference to the key.
          #
          # Otherwise, +k+ is the name of an ActiveRecord attribute. 
          # When this happens, we ignore the value and move on.
          if k == "key"
            map[row["key"]] = row["value"]
          # else
          #   map[k] = v
          end
          # next if k == "value"
        end
      end
    end
  end

  # Adds the key and value pair to the existing hstore.
  #
  #
  def concat(key, value)
    sql =<<-SQL
UPDATE #{table_name}
SET #{hstore_column} = #{hstore_column} || (? => ?)
WHERE id = #{ar_instance.id}
SQL
    ar_klazz.execute_sql([sql, key, value])
  end
  alias :add :concat

  # Returns true if the key in the hstore exists.
  #
  #
  def exist?(key)
    not ar_klazz.where(["exist(#{hstore_column}, ?)", key]).empty?
  end

  # Deletes the key and value pair from the existing hstore.
  #
  #
  def delete(key)
    sql =<<-SQL
UPDATE #{table_name}
SET #{hstore_column} = delete(#{hstore_column}, ?)
WHERE id = #{ar_instance.id}
SQL
    ar_klazz.execute_sql([sql, key])
  end

  # Updates the hstore with entirely new values.
  #
  #
  def update(map)
    sql_bind_str = ar_klazz.build_bind_sql_with(map.size, '(? => ?)', ' ||')

    sql =<<-SQL
UPDATE #{table_name}
SET #{hstore_column} = #{sql_bind_str}
WHERE id = #{ar_instance.id}
SQL

    # map.flatten will convert
    #   {"a" => "b", "c" => "d"}
    # To
    #   ["a", "b", "c", "d"]
    # Adding two arrays yields an array
    ar_klazz.execute_sql([sql] + map.flatten)
  end

#   # APPEND the hstore with entirely new values.
#   #
#   #
#   def APPEND(map)
#     paren_pairs = "|| (? => ?) " * (map.size - 1) + "|| (? => ?)"
# 
#     sql =<<-SQL
# UPDATE #{table_name}
# SET #{hstore_column} = #{hstore_column} #{paren_pairs}
# WHERE id = #{ar_instance.id}
# SQL
# 
#     # Convert
#     #   {"a" => "b", "c" => "d"}
#     # To
#     #   ["a", "b", "c", "d"]
#     args = map.flatten
# 
#     pp [:sql, sql]
#     sql_ary = [sql] + args
#     ar_klazz.execute_sql(sql_ary)
#   end

  def [](key)
    all[key]
  end

  # Perhaps this can be it's own hstore_hash helper
  
  # :foo.hstore['a']          # foo -> 'a'
  #  :foo.hstore + :bar        # foo || bar
  #  :foo.hstore.has_key?('a') # foo ? 'a'
  #  :foo.hstore.include?(bar) # foo @> bar
  # 
  #  You should probably also support taking a ruby hash and supporting it
  #  as an hstore:
  # 
  #  hash = {:a=>:x, :b=>:y}
  #  hash2 = {:b=>:z}
  # 
  #  hash.hstore['a']          # 'a=>x, b=>y'::hstore -> 'a'
  #  hash.hstore + hash2       # 'a=>x, b=>y'::hstore || 'b=>z'::hstore
  #  hash.hstore.has_key?('a') # 'a=>x, b=>y'::hstore ? 'a'
  #  hash.hstore.include?(hash2) # 'a=>x, b=>y'::hstore @> 'b=>z'::hstore
end