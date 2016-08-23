require 'json'

module Loader
      extend self

    
  def orders(json)
    json.map{|data| 
      size = data['size']
      if size == 'SMALL'
        Order.new(data['id'], data['from'], data['to'], Size::SMALL)
      elsif size == 'BIG'
        Order.new(data['id'], data['from'], data['to'], Size::BIG)
      else
        raise ArgumentError, "Size is #{size}.  Argument has to be \"BIG\"or \"SMALL\""
      end
    }
  end

  def drivers(json)
    json.map{|data| 
      print data
      Driver.new(data['id'], data['location']) 
    }
  end
  
end
