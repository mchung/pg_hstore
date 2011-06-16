class HstoreClassMethods

  attr_accessor :ar_klazz, :hstore_column

  def initialize(ar_klazz, hstore_column)
    self.ar_klazz = ar_klazz
    self.hstore_column = hstore_column
  end

  def exist?(query)
    ar_klazz.where(["exist(#{hstore_column}, ?)", query])
  end
  alias :isexists? :exist?

  def exists_any?(query_ary)
    sql_bind_str = ar_klazz.build_bind_sql_with(query_ary.size, '?')
    ar_klazz.where(["exists_any(#{hstore_column}, ARRAY[#{sql_bind_str}])", *query_ary])
  end

  def exists_all?(query_ary)
    sql_bind_str = ar_klazz.build_bind_sql_with(query_ary.size, '?')
    ar_klazz.where(["exists_all(#{hstore_column}, ARRAY[#{sql_bind_str}])", *query_ary])
  end

  # This approach is busted.
  # def akeys
  #   ar_klazz.select("akeys(#{hstore_column})")
  # end

end