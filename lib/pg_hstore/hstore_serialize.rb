# class HStore
#   def load value
#     return unless value
#     eval "{#{value}}"
#   end
#   
#   def dump value
#     return unless value
#     value.map {|xs| xs.join '=>'}.join ', '
#   end
# end
# 
# User < AR::Base  
#   serialize :preferences, HStore.new
# end
# 
# 
# User.where("exist(preferences, 'color')")