#   it "should fetch records where 'title' matches a specific string (using @>)" do
#     res = @conn.exec <<-SQL
# SELECT *, (each(data)).key, (each(data)).value 
# FROM pages_hstore 
# WHERE data @> 'title => "Buy my awesome database book"'
# SQL
#     hstore = HstoreRecord.new(res)
#     hstore.data.count == 1
#     hstore.data[0]["title"].should == "Buy my awesome database book"
#     hstore.data[0]["keywords"].should == "database porn"
#   end


#   it "should test for a key (using ?) and collapse the records" do
#     res = @conn.exec <<-SQL
# SELECT *, (each(data)).key, (each(data)).value 
# FROM pages_hstore 
# WHERE data ? 'title'
# SQL
#     hstore = HstoreRecord.new(res)
#     hstore.data.count.should == 2
#     hstore.data[0]["id"].should == "1"
#     hstore.data[0]["title"].should == "Buy my awesome database book"
#     hstore.data[0]["keywords"].should == "database porn"
#   end
#