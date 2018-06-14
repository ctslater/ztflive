
module Coordinates exposing (RaDec, AltAz, skyToAltAz)

--type alias RaDec = { ra: Float, dec: Float}
type alias RaDec a = { a | ra: Float, dec: Float}

type alias AltAz = { alt: Float, az: Float}

-- LST in radians
-- Obviously obs_lat should not be here
skyToAltAz: RaDec a -> Float -> AltAz
skyToAltAz coord lst =
  let
    obs_lat = degrees 32.0
    hour_angle = lst - (degrees 3.0)
    sin_alt = ((sin (degrees coord.dec)) * (sin obs_lat) +
      (cos (degrees coord.dec)) * (cos obs_lat) * (cos hour_angle))
    alt = asin sin_alt
    cos_a = (sin (degrees coord.dec) - (sin alt)*(sin obs_lat))/((cos alt)*(cos obs_lat))
    az = if sin hour_angle < 0 then acos cos_a else 2*pi - (acos cos_a)
  in
    AltAz alt az
