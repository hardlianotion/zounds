# Zounds

Zounds is a simple Sinatra app that pretends to match drivers to packages-for-delivery.

Features

Install

This was built with ruby 2.3.1 and uses bundler to manage the builds.

FIXME - to be completed...
$ git clone https://github.com/hardlianotion/zounds.git
$ bundle

HOW TO RUN ...

Running the tests

Tests are currently run via

    $ bundle
    $ bundle exec ruby tests/<test-name-here>_tests.rb 
    test-name-here being one of router, server or geography.

API

Client makes a request for routes:

    $ curl -X GET '{"drivers": [ \
                            {"id": "D01234", "location": [44.0, 47.6]}, \
                            {"id": "D01235", "location": [49.0, 47.3]} \
                            ], \
                    "orders": [ \
                            {"id": "O62534", "from": [44.1, 47.5], "to": [44.1, 47.3], "size": "SMALL"},
                            {"id": "O62535", "from": [53.1, 47.5], "to": [53.1, 47.3], "size": "BIG"} \
                          ] \
                } \
                ' http://localhost:9292/routes

If you get a 400 back, it means that you missed out on sending the right JSON. 
If you get a 200 back, it means you can pick out a json response with route information.  This also has
a json format
    
    {
      "deliveries": [ 
                    {"driver": {"id": "D01234", "location": [44.0, 47.6]}, 
                    "order": {"id": "O62534", "from": [44.1, 47.5], "to": [44.1, 47.3], "size": "SMALL"}}
                  ],
      "unused": {
                "drivers": [{"id": "D01235", "location": [49.0, 47.3]}],
                "orders": [{"id": "O62535", "from": [53.1, 47.5], "to": [53.1, 47.3], "size": "BIG"]
              }
      }
  
  In this example (in principle, at least!), driver D01234 has been matched with order O62534, but D01235 and order 
  O62535 have not been matched, ostensibly because the pickup point for O62535 is more than 5 miles from D01235's 
  location.  
  
  The engine matches demand greedily rather than making a true optimal match.  This might mean in this 
  example that D01234 might actually be able to deliver either order, but happens to have picked O62534, while 
  D01235 might well be within range to pick up O62534.
  
  Possible improvements: 
  1. competent route engine
  2. engine request id to match request with response
  
  