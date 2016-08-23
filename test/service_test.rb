ENV['RACK_ENV'] = 'test'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

#Must start first for instrumentation
require 'simplecov'

SimpleCov.start

require 'minitest/autorun'
require 'rack/test'
require 'json'
require 'sinatra'
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
          {'id': '1', 'from':['50', '46'] , 'to': ['70', '44.7'], 'size': 'SMALL'},
          {'id': '1', 'from':['60', '46'] , 'to': ['65', '44.7'], 'size': 'SMALL'}
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
          {'id': '1', 'from':['60', '46'] , 'to': ['65', '44.7'], 'size': 'SMALL'}
        ]
    }
  end
  
  def retrieve_route(json)
    put '/routes', json
    assert_equal 200, last_response.status
    
    returned_note = JSON.parse(last_response.body)
    refute_nil returned_note

    returned_note
  end 
  
  def test_completable_order
    result = retrieve_route(completable_orders)    
  end

  def test_non_completable_order
    result = retrieve_route(non_completable_orders)
  end

  def test_partially_completable_order
    result = retrieve_route(partially_completable_orders)
  end

  def test_wrong_url
    assert(false)
  end

#  def test_add_bum_note_no_content
#    put '/note', {"subject" => "Don't forget"}.to_json
#    assert_equal 400, last_response.status
#  end
#    
#  def test_add_bum_note_no_subject
#    put '/note', {"content" => "To do something"}.to_json
#    assert_equal 400, last_response.status
#  end
#      
#  def test_add_and_retrieve_note
#  # Create a new note, then retrieve it and
#  # assert that we get the same stuff back!
#
#    note = {
#             "subject" => "Don't forget",
#             "content" => "Test add and retrieve note!"
#            }
#
#     note_id = make_a_note(note)
#
#   # Retrieve the note we just created
#     returned_note = retrieve_note(note_id)
#
#   # Check we got the same note back!
#     note.each_key do |k|
#       refute_nil returned_note[k]
#       assert_equal note[k], returned_note[k]
#     end
#  end
end
  
