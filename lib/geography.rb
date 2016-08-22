require "geodna"

MILES_PER_KM = 0.621371192237

def distance(rhs, lhs)
  return MILES_PER_KN * rhs.distance_in_km(lhs)
end
