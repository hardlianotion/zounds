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
  
  puts "***** assigning routes to drivers."

  if drivers.nil? || orders.nil? then
    halt 404
  else
    result = assignRoutes(drivers, orders)
    status  result.status

    jsonp(result.to_json)
  end
end

