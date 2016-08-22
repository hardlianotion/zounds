require 'minitest/autorun'
require 'router'

class TestGeography < Minitest::Test
  
  def setup
    pt1 = [45.0,65.0]
    pt2 = [-45.0, 65.0]
    pt3 = [-45.0, -65.0]
    pt4 = [45.0, -65.0]
    pt5 = [45.0, 145.0]
    pt6 = [-45.0, 145.0]
    pt7 = [-45.0, -145.0]
    pt8 = [45.0, -145.0]

    @points = [pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8]
  end

  def test_mile_to_km_conversion
    for pt in @points do
#      miles = Geography.distance(pt, @points[0])
      km = Geography.distance_in_km(pt, @points[0])
      assert_in_delta(miles, km * Geography.MILES_PER_KM)
    end
  end

  def test_code_excludes_exterior_point
    assert(false)
  end
end

