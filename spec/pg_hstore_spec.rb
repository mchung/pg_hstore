require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

setup_rails_env

class Document < ActiveRecord::Base
end

describe "PgHstore" do

  before(:each) do
    create_pg_hstore_test
    Document.connection.execute <<-SQL
INSERT INTO documents (id, data)
  VALUES (1, 'title=>"How to use PostgreSQL-Hstore", keywords=>"nosql pgsql", description=>"PgSQL does NoSQL"');
INSERT INTO documents (id, data)
  VALUES (2, 'title=>"Wabi Sabi", subtitle => "for Artists, Designers, Poets & Philosophers"');
INSERT INTO documents (id, data)
  VALUES (3, 'author=>"Mr. P Gsql"');
SQL
  end

  after(:each) do
    drop_pg_hstore_test
  end

  def document
    Document.find(1)
  end
  
  def document_unchanged
    Document.find(2)
  end
  
  describe "HstoreType#hstore (object)" do
    before(:each) do
      # Assert the second document's state
      document_unchanged.hstore("data").all.count.should == 2
      document_unchanged.hstore("data").exist?("title").should == true
      document_unchanged.hstore("data").exist?("subtitle").should == true
    end

    after(:each) do
      # Ensure the second document remains unchanged
      document_unchanged.hstore("data").all.count.should == 2
      document_unchanged.hstore("data").exist?("title").should == true
      document_unchanged.hstore("data").exist?("subtitle").should == true
    end
    
    it "should fetch #all data" do
      data = document.hstore("data").all

      data.count.should == 3
      data["title"].should == "How to use PostgreSQL-Hstore"
      data["keywords"].should == "nosql pgsql"
      data["description"].should == "PgSQL does NoSQL"
    end

    describe "#add functionality" do
      it "should #add data" do
        document.hstore("data").add("author", "Marc Chung")
    
        data = document.hstore("data").all
        data.count.should == 4
        data["author"].should == "Marc Chung"
      end
    
      it "should #add data where the key contains single quotes" do
        new_text = "Mary had a little lamb"
        document.hstore("data").add("'new'_text", new_text)
      
        document.hstore("data")["'new'_text"].should == new_text
      end
    
      it "should #add data where the value contains single quotes" do
        new_text = "Mary had a 'little' lamb"
        document.hstore("data").add("new_text", new_text)
      
        document.hstore("data")["new_text"].should == new_text
      end
    
      it "should #add data where the key contains double quotes" do
        new_text = "Mary had a little lamb"
        document.hstore("data").add("\"new\"_text", new_text)
    
        document.hstore("data")["\"new\"_text"].should == new_text
      end
    
      it "should #add data where the value contains double quotes" do
        new_text = "Mary had a \"little\" lamb"
        document.hstore("data").add("new_text", new_text)
    
        document.hstore("data")["new_text"].should == new_text
      end

      # Edge case.
      it "should #add all sorts of data" do
        new_text = "Mary's lamb was a \"little\" lamb whose fleece\"s [sic] was white as snow'"
        document.hstore("data").add("\"new\"_text'", new_text)
    
        document.hstore("data")["\"new\"_text'"].should == new_text        
      end
    end

    it "should return true if a key #exist?" do
      document.hstore("data").exist?("title").should == true
    end

    it "should return false if a key does not #exist?" do
      document.hstore("data").exist?("haiku").should == false
    end

    it "should #delete data" do
      document.hstore("data").delete("title")

      data = document.hstore("data").all
      data.count.should == 2
      data["title"].should == nil
    end

    describe "#update functionality" do
      it "should #update data" do
        new_data = {"ikku1" => "I see you rolling", 
                    "ikku2" => "Around town with my girlfriend",
                    "ikku3" => "And I'm like haiku"}
        document.hstore("data").update(new_data)
      
        data = document.hstore("data").all
        data.count.should == 3
        data["ikku1"].should == new_data["ikku1"]
        data["ikku2"].should == new_data["ikku2"]
        data["ikku3"].should == new_data["ikku3"]
      end

      it "should #update data where the key contains single quotes" do
        new_text = "Mary had a little lamb"
        document.hstore("data").update({"'new'_text" => new_text})
      
        document.hstore("data")["'new'_text"].should == new_text
      end
      
      it "should #update data where the value contains single quotes" do
        new_text = "Mary had a 'little' lamb"
        document.hstore("data").update({"new_text" => new_text})
              
        document.hstore("data")["new_text"].should == new_text
      end
      
      it "should #update data where the key contains double quotes" do
        new_text = "Mary had a little lamb"
        document.hstore("data").update({"\"new\"_text" => new_text})
      
        document.hstore("data")["\"new\"_text"].should == new_text
      end
      
      it "should #update data where the value contains a double quote" do
        new_text = "Mary had a \"little\" lamb"
        document.hstore("data").update({"new_text" => new_text})
      
        document.hstore("data")["new_text"].should == new_text
      end
      
      it "should #update all sorts of data" do      
        new_text = "Mary's lamb was a \"little\" lamb whose fleece\"s [sic] was white as snow'"
        document.hstore("data").update({"\"new\"_text'" => new_text})
      
        document.hstore("data")["\"new\"_text'"].should == new_text        
      end
    end

    it "should #query data" do
      document.hstore("data")["title"].should == "How to use PostgreSQL-Hstore"
    end

  end

  describe "PG HStore Query Interface (class)" do

    it "should return records with #exist - comprehensive" do
      results = Document.hstore("data").exist?("title")
      results.count.should == 2
    end
    
    it "should return records with #exist - partial" do
      results = Document.hstore("data").exist?("subtitle")
      results.count.should == 1
    end

    it "should return any record with #exists_any - ex 1" do
      results = Document.hstore("data").exists_any?(["subtitle", "title"])
      results.count.should == 2
    end

    it "should return any record with #exists_any - ex 2" do
      results = Document.hstore("data").exists_any?(["keywords", "author"])
      results.count.should == 2
    end

    it "should return records with #exists_all - ex 2" do
      results = Document.hstore("data").exists_all?(["title", "subtitle"])
      results.count.should == 1
    end

    it "should return records with #exist_all - ex 3" do
      results = Document.hstore("data").exists_all?(["subject", "body"])
      results.count.should == 0
    end

    # it "should return #akeys" do
    #   results = Document.where(:id => 1).hstore("data").akeys
    #   pp results
    # end
  end

  # describe "Document#hstore (class)" do
  #   it "should run queries" do
  #     Document.hstore("data").where("color").exist?
  #     Document.hstore("data").where(["color", "foo"]).exists_all?
  #     Document.hstore("data").where(["color", "foo"]).exists_any?
  #     Document.hstore("data").where("color").akeys
  #     Document.hstore("data").skeys
  #     Document.hstore("data").avals
  #     Document.hstore("data").svals
  #     Document.hstore("data").to_array
  #   end
  # end

end