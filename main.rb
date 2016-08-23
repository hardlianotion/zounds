require 'sinatra'
require 'router'
require './lib/loader'
require 'json'

before do
  content_type 'application/json'
end

def jsonp(json)
  params[:callback] ? "#{params[:callback]}(#{json})" : json
end

def invalid?(result)
  result['deliveries'].nil? || result['unused'].nil?
end

put '/routes' do

  data = JSON.parse(request.body.read) 
  
  if data.nil? || data['drivers'].nil? || data['orders'].nil?
    halt 400
  end
  
  drivers = Loader.drivers(data['drivers'])
  orders = Loader.orders(data['orders'])

  if drivers.nil? || orders.nil? then
    halt 400
  else
    #FIXME some error handling would be nice
    #FIXME - clumsy
    orderIds = orders.map{|driver| driver.id}
    driverIds = drivers.map{|order| order.id}
    
    idOrders = Hash[orderIds.zip(orders)]
    idDrivers = Hash[driverIds.zip(drivers)]

    result = assignRoutes(idDrivers, idOrders)
    print result
    resultJson = result.to_json
    
    if resultJson.nil? || invalid?(resultJson)
      halt 500
    end
     
    jsonp(resultJson)
  end
end

