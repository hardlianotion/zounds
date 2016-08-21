

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
      'size' => :size
    }.to_json(*a)
  end
end

class UnusedOpportunities
  attr_reader :drivers, :orders

  def initialize(drivers, orders)
    @drivers = drivers
    @orders = orders
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
      'deliveries' => :deliveries.to_json,
      'unused' => {
          'drivers' => :unused.drivers,
          'orders' => :unused.orders
        }.to_json(*a)
    }
  end
end

def assignRoutes(drivers, orders)
  Result.new([], UnusedOpportunities.new([], []))
end
