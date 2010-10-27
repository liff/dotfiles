# -*- Ruby -*-

def sql(query)
  ap(ActiveRecord::Base.connection.select_all(query))
end 

def sqly(query)
  y(ActiveRecord::Base.connection.select_all(query))
end

