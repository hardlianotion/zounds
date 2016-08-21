ENV['RACK_ENV'] = 'test'

#Must start first for instrumentation
require 'simplecov'

SimpleCov.start

require 'minitest/autorun'
require 'rack/test'
require 'json'
require 'router'

class TestService < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def completable_orders 
    {
      'drivers': [
          {'id': '1', 'location': ['45', '45']},
          {'id': '1', 'location': ['48', '48']}
        ], 
      'orders':[
          {'id': '1', 'from':['45', '46'] , 'to': ['45', '44.7'], 'size': 'SMALL'},
          {'id': '1', 'from':['48', '46'] , 'to': ['48', '44.7'], 'size': 'SMALL'}
        ]
    }
  end

  def non_completable_orders 
    {
      'drivers': [
          {'id': '1', 'location': ['45', '45']},
          {'id': '1', 'location': ['48', '48']}
        ], 
      'orders':[
          {'id': '1', 'from':['50', '46'] , 'to': ['50', '44.7'], 'size': 'SMALL'},
          {'id': '1', 'from':['60', '46'] , 'to': ['60', '44.7'], 'size': 'SMALL'}
        ]
    }
  end

  def partially_completable_orders 
    {
      'drivers': [
          {'id': '1', 'location': ['45', '45']},
          {'id': '1', 'location': ['48', '48']}
        ], 
      'orders':[
          {'id': '1', 'from':['45', '46'] , 'to': ['45', '44.7'], 'size': 'SMALL'},
          {'id': '1', 'from':['60', '46'] , 'to': ['48', '44.7'], 'size': 'SMALL'}
        ]
    }
  end

  def test_completable_order
    assert(false)    
  end

  def test_non_completable_order
    assert(false)
  end

  def test_partially_completable_order
    assert(false)
  end

  def test_wrong_url
    assert(false)
  end

end
  
