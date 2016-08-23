require 'kdtree'
require 'json'
require 'geography.rb'

  MAX_PERMITTED_DISTANCE = 5.0
  DRIVER_DEPTH = 5 #max possible 255 - max number of nearest neighbour drivers we look for in a tree
  ORDER_DEPTH = 5 #max possible 255 - max number of nearest neighbour orders we look for in a tree

  class Driver
    attr_reader :id, :location
    
    def initialize(id, location)
      @id = id
      @location = location
    end
  
    def to_json(*a)
      {
        'id' => :id,
        'location' => :location,
      }.to_json(*a)
    end
  end
  
  class Size
    SMALL = 1
    BIG = 3
  end
  
  class Order
    attr_reader :id, :from, :to, :size
    
    def initialize(id, from, to, size)
      @id = id
      @from = from
      @to = to
      @size = size
    end
  
    def to_json(*a)
      {
        'id' => :id,
        'from' => :from,
        'to' => :to,
        'size' => :size == Size::SMALL ? 'SMALL':'BIG' 
      }.to_json(*a)
    end
  end
  
  class Delivery
    attr_reader :driver, :order
    def initialize(driver, order)
      @driver = driver
      @order = order
    end
    
    def to_json(*a)
      {
        'driver' => :driver,
        'order' => :order
      }.to_json(*a)
    end
  end 
  
  class UnusedOpportunities
    attr_reader :drivers, :orders
  
    def initialize(drivers, orders)
      @drivers = drivers
      @orders = orders
    end
    
    def to_json(*a)
      {
        'drivers' => :drivers,
        'orders' => :orders
      }.to_json(*a)
    end
  end

  class Result
    attr_reader :deliveries, :unused
  
    def initialize(deliveries, unused)
      @deliveries = deliveries
      @unused = unused
    end
  
    def to_json(*a)
      {
        'deliveries' => :deliveries,
        'unused' => :unused 
      }.to_json(*a)
    end
  end
  
  def assignRoutes(drivers, orders)
    orderIds = orders.keys.to_set
    driverIds = drivers.keys.to_set
    
    orderPts = orders.values.map{|order| [order.from[0], order.from[1], order.id]}
    driverPts = drivers.values.map{|driver| [driver.location[0], driver.location[1], driver.id]}
    
    orderTree = Kdtree.new(orderPts)
    driverTree = Kdtree.new(driverPts)
    
    deliveries = orders.values.inject([]) {|result, order|  
      #use the trees to look for nearest neighbouring drivers for each order.
      #For small packages, we use the trees to look up nearest neighbouring orders to 
      #fill each driver's car
      processed = processOrder(order.id, orders, orderTree, drivers, driverTree, orderIds, driverIds)
      if processed && !processed.empty?
       result.push(processed)
      else 
        result
      end
    }
    
    unfilledOrders = orderIds.map {|id| orders[id]}
    unemployedDrivers = driverIds.map {|id| drivers[id]}
    Result.new(deliveries.flatten, UnusedOpportunities.new(unemployedDrivers, unfilledOrders))
  end

private

  #FIXME - messy
  def processOrder(orderId, orders, orderTree, drivers, driverTree, orderIds, driverIds)
    order = orders[orderId]
    from = order.from
    result = []
    nearToFarIds = driverTree.nearestk(from[0], from[1], DRIVER_DEPTH)
    
    for id in nearToFarIds do
      if !driverIds.include?(id)
        next
      end

      driver = drivers[id]
      if Geography.distance(driver.location, order.from) > MAX_PERMITTED_DISTANCE
        break
      else
        orderIds.delete(orderId) 
        result.push(Delivery.new(driver, order))

        if order.size ==Size::BIG 
          driverIds.delete(id)
        else
          processed = processDriver(id, orders, orderTree, drivers, driverTree, orderIds, driverIds)
          if processed && !processed.empty?
            result.push(processed)
          end
        end
        break
      end
    end
    return result.empty? ? nil: result
  end
  
  #FIXME - messy
  def processDriver(driverId, orders, orderTree, drivers, driverTree, orderIds, driverIds)
    driver = drivers[driverId]
    location = driver.location
    nearToFarIds = orderTree.nearestk(location[0], location[1], ORDER_DEPTH)
    result = []    
    driverLoad = 1
    for id in nearToFarIds do
      order = orders[id]
      if Geography.distance(driver.location,order.from) > MAX_PERMITTED_DISTANCE
        break
      else 
        if driverLoad == 3
          driverIds.delete(driverId)
          break
        end

        if order.size == 1
          driverLoad += 1
          orderIds.delete(id) 
          result.push(Delivery.new(driver, order))
        end
      end
    end
    return result.empty? ? nil : result
  end
