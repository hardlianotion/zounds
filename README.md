# Zounds

Zounds is a simple Sinatra web app that pretends to match drivers to packages-for-delivery.

Install

This was built with ruby 2.3.1 with ruby-dev, using bundler to manage the builds.  

This is interview code for a position at Zoomer in 2016.  Updates to the code would be surprising.

    $ git clone https://github.com/hardlianotion/zounds.git
    $ bundle
    $ gem build zounds.gemspec
    $ gem install zounds-0.1.0

taking care to ensure all parts of your ruby system have some idea that bundler and gem 
can work together.  Known installation problems include

* Current version of sinatra (1.4.7) clashes with latest version of rack (2.0.1).  Rack 1.6.4 is compatible.

HOW TO RUN ...

Running the tests

Tests are currently run from the project root via

    $ bundle
    $ bundle exec ruby test/<test-name-here>_tests.rb 
    
test-name-here being one of router, server or geography.

server_tests currently are not currently connecting to server code, so best to check out running the
app itself for 'real'.

To start the service

    $ rackup

Open up another client and type in an instruction aimed at the api.

API

Client makes a request for routes.  Test it out on the command line:

    $ curl -X PUT -d     "{ \
      \"drivers\": [ \
          {\"id\": 1, \"location\": [45, 45]}, \
          {\"id\": 2, \"location\": [48, 48]} \
        ],  \
      \"orders\":[ \
          {\"id\": 1, \"from\":[45, 45] , \"to\": [45, 44.7], \"size\": \"SMALL\"}, \
          {\"id\": 2, \"from\":[48, 48] , \"to\": [48, 44.7], \"size\": \"SMALL\"} \
        ] \
    }" http://localhost:9292/routes

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

If you receive a 500, something unfortunate has happened in the engine (not all the states are fully enumerated and
accounted for) and you will have nothing to parse.
      
In this example (in principle, at least!), driver D01234 has been matched with order O62534, but D01235 and order 
O62535 have not been matched, ostensibly because the pickup point for O62535 is more than 5 miles from D01235's 
location.  
  
The engine matches demand greedily rather than making a true optimal match.  This might mean in this 
example that D01234 might actually be able to deliver either order, but happens to have picked O62534, while 
D01235 might well be within range to pick up O62534, but cannot pick up on O62535, so the opportunity is missed.
  
  Possible improvements: 
  1. competent route engine
  2. engine request id to match request with response
  
  
