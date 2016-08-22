require 'json'

module Loader

  def drivers(json)
    json.map{|data| 
      size = data['size']
      if size == 'SMALL'
        [data['id'], Order.new(data['id'], data['from'], data['to'], Size::SMALL)]
      elsif size == 'BIG'
        [data['id'], Order.new(data['id'], data['from'], data['to'], Size::BIG)]
      else
        raise ArumentError, 'Argument has to be \"BIG\"or \"SMALL\"'
      end
    }.to_h
  end

  def orders(json)
    json.map{|data| [data['id'], Order.new(data['id'], data['location']) ]}.to_h
  end
  
end
