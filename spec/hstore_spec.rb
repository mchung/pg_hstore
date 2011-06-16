require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "hstore spec" do

  before(:all) do
    @conn = PGconn.connect("localhost", 5432, "", "", "pg_hstore_test")
  end

  after(:all) do
    @conn.close
  end

  before(:each) do
    @conn.exec <<-SQL
CREATE TABLE documents (
  id              serial,
  data            hstore
);
SQL
    @conn.exec <<-SQL
INSERT INTO documents (id, data)
  VALUES (1, 'title=>"How to use PostgreSQL-Hstore", keywords=>"nosql pgsql", description=>"PgSQL does NoSQL"');
INSERT INTO documents (id, data)
  VALUES (2, 'title=>"Wabi Sabi", subtitle => "for Artists, Designers, Poets & Philosophers"');
INSERT INTO documents (id, data)
  VALUES (3, 'author=>"Mr. P Gsql"');
SQL
  end

  after(:each) do
    @conn.exec <<-SQL
DROP TABLE documents
SQL
  end

  it "should fetch all the keys in multiple rows" do
    res = @conn.exec <<-SQL
SELECT (each(data)).key, (each(data)).value
FROM documents
WHERE id = 1
SQL
    rv = {}
    res.each do |r|
      rv[r["key"]] = r["value"]
    end

    rv["title"].should == "How to use PostgreSQL-Hstore"
    rv["keywords"].should == "nosql pgsql"
  end

#   it "should fetch all values using the .* operator" do
#     res = @conn.exec <<-SQL
# SELECT *, (each(data)).*
# FROM documents
# WHERE id = 1
# SQL
#     puts "incoming"
#     res.each_with_index do |r, i|
#       pp [:idx, i, r]
#     end
#   end

  it "should fetch and rename columns" do
    res = @conn.exec <<-SQL
SELECT data->'title' as title, 
       data->'keywords' as keywords 
FROM documents 
WHERE id = 1
SQL
    res[0]["title"].should == "How to use PostgreSQL-Hstore"
    res[0]["keywords"].should == "nosql pgsql"
  end
  
  it "should fetch all headers in one row (cheating with two queries)" do
    res = @conn.exec <<-SQL
SELECT skeys(data) 
FROM documents 
WHERE id = 1
SQL
    headers_sql = []
    res.each do |r|
      headers_sql << "data->'#{r["skeys"]}' as #{r["skeys"]}"
    end

    res = @conn.exec <<-SQL
SELECT 
#{headers_sql.join(', ')}
FROM documents 
WHERE id = 1
SQL
    res[0]["title"].should == "How to use PostgreSQL-Hstore"
    res[0]["keywords"].should == "nosql pgsql"
    res[0]["description"].should == "PgSQL does NoSQL"
  end
  
  it "should fetch all documents where the key 'author' exists" do
    res = @conn.exec <<-SQL
SELECT * 
FROM documents
WHERE exists_any(data, ARRAY['author']);
SQL
    res[0]["id"].should == "3"

    res = @conn.exec <<-SQL
SELECT * 
FROM documents
WHERE data ?& ARRAY['author'];
SQL
    res[0]["id"].should == "3"
  end

  # TODO: A query that returns a single row result, +res+, such that:
  #       res[0]["title"]
  #       res[0]["keywords"]
  # 
  # title            |     keywords          |    description
  # -----------------+-----------------------+------------------
  # Buy my awesome   |     Database porn     |    awesome boook
  # 
  # So there is no need for the post-processing collapsing function.
  # Is there some PG/PLSQL function that does this?
  # Can I use hstore_to_matrix?
  it "should fetch and a query that returns a single row of results" do
    # pending
  end

end
