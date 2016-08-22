require 'minitest/autorun'


class TestGeography < Minitest::Test
  
  def setup
    pt1 = Point.new(45.0,65.0)
    pt2 = Point.new(-45.0, 65.0)
    pt3 = Point.new(-45.0, -65.0)
    pt4 = Point.new(45.0, -65.0)
    pt5 = Point.new(45.0, 145.0)
    pt6 = Point.new(-45.0, 145.0)
    pt7 = Point.new(-45.0, -145.0)
    pt8 = Point.new(45.0, -145.0)

    @points = [pt1, pt2, pt3, pt4, pt5, pt6, pt7, pt8]
  end

  def test_to_cartesian_and_back_invariant
    for pt in @points do
      xyz = latlon_to_cartesian(pt)
      ptAgain = cartesian_to_latlon(xyz)
      
      assert_in_delta(distance(pt, ptAgain), 0.0)
    end
  end

  def test_code_excludes_exterior_point
    assert(false)
  end
end

