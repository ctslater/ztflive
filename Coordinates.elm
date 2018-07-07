
module Coordinates exposing (RaDec, AltAz, skyToAltAz, jdToLST, utcToLST, daysJD)

import Time exposing (Time)

--type alias RaDec = { ra: Float, dec: Float}
type alias RaDec a = { a | ra: Float, dec: Float}

type alias AltAz = { alt: Float, az: Float}

-- Deg/radians situation currently makes no sense:
-- Coord is in degrees
-- Lat is radians
-- LST in radians
-- AltAz is in radians
skyToAltAz: RaDec a -> Float -> Float -> AltAz
skyToAltAz coord obs_lat lst =
  let
    hour_angle = lst - (degrees coord.ra)
    sin_alt = ((sin (degrees coord.dec)) * (sin obs_lat) +
      (cos (degrees coord.dec)) * (cos obs_lat) * (cos hour_angle))
    alt = asin sin_alt
    cos_a = (sin (degrees coord.dec) - (sin alt)*(sin obs_lat))/((cos alt)*(cos obs_lat))
    az = if sin hour_angle < 0 then acos cos_a else 2*pi - (acos cos_a)
  in
    AltAz alt az

mod2Pi: Float -> Float
mod2Pi x = let
    rev = x / (2 * pi)
  in 2 * pi * (rev - toFloat(floor(rev)))

daysJD: Time -> Float
daysJD time =
  let
    days_since_unix_epoch = time/(24 * 3600 * 1000.0)
    -- Unix epoch = JD 2440587.5
  in days_since_unix_epoch + 2440587.5

-- longitude is in radians
jdToLST: Time -> Float -> Float
jdToLST jd longitude = 
  let
    time_u = jd - 2451545.0
    era = 2 * pi * (0.7790572732640 + 1.00273781191135448 * time_u)
  in
    mod2Pi (era + longitude)

-- \theta (t_{U})=2\pi (0.7790572732640+1.00273781191135448t_{U})
utcToLST: Time -> Float -> Float
utcToLST time longitude = jdToLST (daysJD time) longitude