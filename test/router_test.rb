require "minitest/autorun"
require "router"
require "geodna"


class TestRouter < Minitest::Test
  
  def setup
    d1 = Driver.new(1, 40.1)
    d2 = Driver.new(2, 40.11)
    d3 = Driver.new(3,40.122)
    d4 = Driver.new(4, 40.13)
    drivers = [d1, d2, d3, d4]
    
    o1 = Order.new(1, 39.99, 40.11, Size::SMALL)
    o2 = Order.new(2, 40.12, 40.13, Size::SMALL)
    o3 = Order.new(3, 40.13, 39.96, Size::BIG)
    o4 = Order.new(4, 40.13, 39.97, Size::SMALL)
    o5 = Order.new(5, 39.98, 39.982, Size::SMALL)
    o6 = Order.new(6, 39.97, 40.12, Size::BIG)
    o7 = Order.new(7, 39.89, 40.12, Size::SMALL)
    o8 = Order.new(8, 49.99, 40.0, Size::SMALL)
    o9 = Order.new(9, 39.97, 39.99, Size::BIG)
    o10 = Order.new(10, 39.98, 40.4, Size::BIG)
    o11 = Order.new(11, 40.10, 40.3, Size::SMALL)

    orders = [o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11]
    @result = assignRoutes(drivers, orders)
  end
  
  def test_all_delivered_packages_are_in_reach_of_drivers
    deliveries = @results.deliveries

    for delivery in deliveries do
      #FIXME - refactor needed to accommodate feasibility policy
      assert(distance(delivery.driver.position, delivery.order.origin) <= 5.0)
    end
  end

  def test_no_driver_has_more_than_three_packages
    deliveries = @result.deliveries
    ids = deliveries.map { |delivery| delivery.driver.id }.uniq
    
    for id in ids
      driverJobs = deliveries.find_all(|delivery| delivery.driver.id == id)
      assert(driverJobs.length <= 3)
    end
  end

  def test_drivers_with_large_package_have_one_delivery
    deliveries = @result.deliveries
    ids = deliveries.map { |delivery| delivery.driver.id }.uniq
    
    for id in ids
      driverJobs = deliveries.find_all(|delivery| delivery.driver.id == id && delivery.order.size == Size::BIG)
      assert(driverJobs.length == 1)
    end
  end

  def test_unused_drivers_do_not_deliver_orders
    unused = @result.unused
    deliveries = @result.deliveries
    drivers = unused.drivers
    unusedIds = drivers.map { |driver| driver.id }

    mixedUpDrivers = deliveries.find {|delivery| unusedIds.index(delivery.driver.id) != nil }
    assert(mixedUpDrivers.length == 0)
  end

  def test_undelivered_orders_are_out_of_reach_of_drivers
    unused = @result.unused
    orders = unused.orders
    deliveries = @result.deliveries
    overlookedOrders = orders.find_all { |order| deliveries.find_all{ |delivery| distance(delivery.driver.position, order.position) <= 5.0 } }

    assert(overlookedOrders.length == 0)
  end
end

