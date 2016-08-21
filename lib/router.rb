  class Driver
    attr_reader :id, :location
    
    def initialize(id, location)
      @id = id
      @location = location
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
  end

  class Result
    attr_reader :deliveries, :unused

    def initialize(deliveries, unused)
      @deliveries = deliveries
      @unused = unused
    end
  end

  def assignRoutes(drivers, orders)
  end
