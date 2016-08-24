$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest/autorun'
require 'router'
require 'loader'
require 'json'


class TestRouter < Minitest::Test
  
  def setup
    d1 = Driver.new(1, [40.1, 40.1])
    d2 = Driver.new(2, [40.11, 40.1])
    d3 = Driver.new(3,[40.122, 40.1])
    d4 = Driver.new(4, [40.13, 40.1])
    @drivers = {1 => d1, 2 => d2, 3 => d3, 4 => d4}
    
    o1 = Order.new(1, [39.99, 40.1], [40.11, 40.1], Size::SMALL)
    o2 = Order.new(2, [40.12, 40.1], [40.13, 40.1], Size::SMALL)
    o3 = Order.new(3, [40.13, 40.1], [39.96, 40.1], Size::BIG)
    o4 = Order.new(4, [40.13, 40.1], [39.97, 40.1], Size::SMALL)
    o5 = Order.new(5, [39.98, 40.1], [39.982, 40.1], Size::SMALL)
    o6 = Order.new(6, [39.97, 40.1], [40.12, 40.1], Size::BIG)
    o7 = Order.new(7, [39.89, 40.1], [40.12, 40.1], Size::SMALL)
    o8 = Order.new(8, [49.99, 40.1], [40.0, 40.1], Size::SMALL)
    o9 = Order.new(9, [39.97, 40.1], [39.99, 40.1], Size::BIG)
    o10 = Order.new(10, [39.98, 40.1], [40.4, 40.1], Size::BIG)
    o11 = Order.new(11, [40.10, 40.1], [40.3, 40.1], Size::SMALL)

    @orders = {1 => o1, 2 => o2, 3 => o3, 4 => o4, 5 => o5, 6 => o6, 7 => o7, 8 => o8, 9 => o9, 10 => o10, 11 => o11}
    @result = assignRoutes(@drivers, @orders)
  end
  
  def test_all_delivered_packages_are_in_reach_of_drivers
    deliveries = @result.deliveries
  
    for delivery in deliveries do
      #FIXME - refactor needed to accommodate feasibility policy
      assert(Geography.distance(delivery.driver.location, delivery.order.from) <= 5.0)
    end
  end

  def test_no_driver_has_more_than_three_packages
    deliveries = @result.deliveries
    ids = deliveries.map { |delivery| delivery.driver.id }.uniq 
    
    for id in ids do
      driverJobs = deliveries.select{ |delivery| delivery.driver.id == id }
      assert(driverJobs.length <= 3, "#{id} has #{driverJobs.length} orders")
    end
  end

  def test_drivers_with_large_package_have_one_delivery
    deliveries = @result.deliveries
    ids = deliveries.map { |delivery| delivery.driver.id }.uniq
    
    for id in ids
      driverJobs = deliveries.select{ 
        |delivery| delivery.driver.id == id && delivery.order.size == Size::BIG 
      }
      assert(driverJobs.length <= 1, "#{id} has size #{Size::BIG} and #{driverJobs.length} orders")
    end
  end
  
  def test_orders_either_delivered_or_unused
    used = @result.deliveries.map {|delivery| delivery.driver }.uniq
    unused = @result.unused.drivers
    drivers = used + unused
    checked = drivers & @drivers.values
    assert(checked.length == @drivers.length, "used + unused #{checked.length}, all drivers #{@drivers.length}")
  end

  def test_all_drivers_either_delivering_or_unused
    used = @result.deliveries.map {|delivery| delivery.order }.uniq
    unused = @result.unused.orders.uniq
    orders = used + unused
    checked = orders & @orders.values
    assert(checked.length == @orders.length)
  end

  def test_no_two_drivers_carry_the_same_load
    print "6\n"
    assert(false)   
  end
 
  def test_no_load_is_carried_by_multiple_drivers
    print "7\n"
    assert(false)    
  end

  def test_unused_drivers_do_not_deliver_orders
    unused = @result.unused
    deliveries = @result.deliveries
    drivers = unused.drivers
    unusedIds = drivers.map { |driver| driver.id }
    usedIds = deliveries.map { |delivery| delivery.driver.id }

    mixedUpDrivers = unusedIds & usedIds
    assert(mixedUpDrivers.length == 0)
  end

  def test_unused_orders_cannot_be_delivered
    unused = @result.unused
    deliveries = @result.deliveries
    orders = unused.orders
    unusedIds = orders.map { |order| order.id }
    usedIds = deliveries.map { |delivery| delivery.order.id }

    mixedUpOrders = unusedIds & usedIds
    assert(mixedUpOrders.length == 0)
  end

  def test_undelivered_orders_are_out_of_reach_of_drivers
    unused = @result.unused
    drivers = unused.drivers
    orders = unused.orders
    deliveries = @result.deliveries
    
    if orders  
      overlookedOrders = orders.select {|order| 
        deliveries.select {|delivery| 
          refute(Geography.distance(delivery.driver.location, order.from) <= 5.0 &&
          delivery.order.size == Size::SMALL)
        } 
      }
      if drivers
        overlookedOrders = orders.select {|order| 
          drivers.select {|driver| 
            assert(Geography.distance(driver.location, order.from) >  5.0) 
          } 
        }
      end
    end

  end

  def test_driver_to_json
    json = JSON.parse(@drivers[1].to_json)

    json2 = @drivers[1].to_json
    assert json['id'] == 1
    assert json['location'] == [40.1, 40.1] 
  end

  def test_order_to_json
    json = JSON.parse(@orders[1].to_json)
    
    assert(json["id"] == 1, "#{json["id"]} is not 1")
    assert(json['from'] == [39.99, 40.1], "#{json['from']} is not 39.99")
    assert(json['to'] == [40.11, 40.1])
  end

  def test_result_to_json
    json = @result
    
    #assert json["deliveries"].size == 2
  end

  def completable_orders 
    {
      'drivers'=> [
          {'id' => 1, 'location' => [45, 45]},
          {'id'=> 2, 'location'=> [48, 48]}
        ], 
      'orders' =>[
          {'id' => 1, 'from' => [45, 45] , 'to'=> [45, 44.7], 'size' => 'SMALL'},
          {'id'=> 2, 'from' => [48, 48] , 'to'=> [48, 44.7], 'size'=> 'SMALL'}
        ]
    }
  end  

  def test_deliveries_to_json
    json = self.completable_orders

    drivers = Loader.drivers(json['drivers'])
    orders = Loader.orders(json['orders'])

    driverIds = orders.map{|driver| driver.id}
    orderIds = drivers.map{|order| order.id}
    
    idOrders = Hash[orderIds.zip(orders)]
    idDrivers = Hash[driverIds.zip(drivers)]
    
    result = assignRoutes(idDrivers, idOrders)
    assert result.deliveries.length == 2
  end

  def test_unused_to_json
  end
end

