require 'kdtree'


module Geography

  MILES_PER_KM = 0.621371192237
  RADIUS_OF_EARTH = 6378100.0
  SQRT2 = Math.sqrt(2.0)

  class Point
    attr_reader :lat, :lon

    def initialize(latlon )
      @lat = latlon[0]
      @lon = latlon[1]
    end

    def coordinates
      return [ :lat, :lon ]
    end

    def add_vector( dy, dx )
      coords = Geography.add_vector(self.coordinates , dy, dx )
      Geography::Point.new( *coords )
    end

    def distance_in_km( point )
      Geography.distance_in_km( self.coordinates, point)
    end
  end

  def add_vector( point, dy, dx )
    lat = point[0]
    lon = point[1]
    return [
      f_mod( ( lat + 90.0 + dy  ), 180.0 ) - 90.0,
      f_mod( ( lon + 180.0 + dx ), 360.0 ) - 180.0
    ]
  end
  
  def distance_in_km(l, r)
      # if l[1] and r[1] have different signs, we need to translate
      # everything a bit in order for the formulae to work.
      if l[1] * r[1] < 0.0 && ( l[1] - r[1] ).abs > 180.0
          l = add_vector( l, 0.0, 180.0 )
          r = add_vector( r, 0.0, 180.0 )
      end
      x = ( deg2rad(r[1]) - deg2rad(l[1]) ) * Math.cos( ( deg2rad(l[0]) + deg2rad(r[0])) / 2.0 )
      y = ( deg2rad(r[0]) - deg2rad(l[0]) )
      d = Math.sqrt( x*x + y*y ) * RADIUS_OF_EARTH
      return d / 1000.0
  end

  def distance(l,r)
    return MILES_PER_KM * distance_in_km(l, r)
  end

  private

  def f_mod( x, m )
    return ( x % m + m ) % m;
  end

  def deg2rad(d)
      ( d / 180.0 ) * Math::PI
  end

  def rad2deg(r)
      ( r / Math::PI ) * 180
  end

end
