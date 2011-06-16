# 
# # Given a set of pgresults from an hstore, this class will combine data
# # into a single result set 
# # 
# # Collapses data.
# class HstoreRecord
#   
#   def initialize(pgresult)
# 
#     # Maps data: (key -> value) : (record ID -> actual record)
#     @datamap = {}
#     pgresult.each do |row|
#       # Set or create a set in the data map
#       id = row["id"]
#       if @datamap[id].nil?
#         @datamap[id] = {}
#       end
#       set = @datamap[id]
# 
#       row.each do |k, v|
#         next if k == "value"
#         if k == "key" # we are looking at an hstore attribute
#           set[row["key"]] = row["value"]
#         else # we are looking at a regular row record
#           set[k] = v
#         end
#       end
#     end
#   end
#   
#   def data
#     @datamap.values
#   end
# end
