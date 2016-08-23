require 'sinatra'
require 'router'
require 'json'

before do
  content_type 'application/json'
end

def jsonp(json)
  params[:callback] ? "#{params[:callback]}(#{json})" : json
end

get '/routes' do
  drivers = Loader.drivers(params[:drivers])
  orders = Loader.orders(params[:orders])

  if drivers.nil? || orders.nil? then
    halt 404
  else
    #FIXME bad path handling here 
    result = assignRoutes(drivers, orders)
    status  result.status
    
    resultJson = result.to_jason
    if !resultJason
      halt 500
    end
    jsonp(resultJson)
  end
end

