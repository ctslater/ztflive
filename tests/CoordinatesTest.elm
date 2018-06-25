module CoordinatesTest exposing (..)

import Expect exposing (Expectation, FloatingPointTolerance(Absolute) )
import Test exposing (..)
import Date

import Coordinates exposing (RaDec, AltAz, skyToAltAz, utcToLST, jdToLST, daysJD)

-- skyToAltAz: RaDec a -> Float -> AltAz
suite : Test
suite =
    describe "The Coordinates module "
        [ test "Converts RaDec" <|
            \_ -> let
                palomar_lon = -116.863
                palomar_lat = 33.356
                jd = 2458290.5
                lst = jdToLST jd palomar_lon
            in
                skyToAltAz {ra = 90.0, dec = 20.0} (degrees palomar_lat) lst |> 
                    expectAltAz (AltAz (degrees 33.80) (degrees 272.980)),

          test "Compute JD" <|
          \_ -> let
              -- Have to add -0000 to specify UTC, or else Date assumes it is local tz
              test_date = "2006-01-15T21:24:37.5-0000"
              test_time = case Date.fromString test_date of
                    Ok date -> Date.toTime date
                    Err _ -> 0.0
            in daysJD test_time |> Expect.within (Absolute 0.1) 2453751.39209,

          test "Compute unix time" <|
          \_ -> let
              test_date = "2006-01-15T21:24:37.5-0000"
              test_time = case Date.fromString test_date of
                    Ok date -> Date.toTime date
                    Err _ -> 0.0
            in test_time |> Expect.within (Absolute 100) (1137360277.5*1000),

          test "Computes LST " <|
          \_ -> let
              test_date = "2006-01-15T21:24:37.5-0000"
              test_time = case Date.fromString test_date of
                    Ok date -> Date.toTime date
                    Err _ -> 0.0
              longitude = 120.0
            in 
              (utcToLST test_time longitude) |> Expect.within (Absolute 0.01) (degrees 196.342828059)
        ]

expectAltAz: AltAz -> AltAz -> Expectation 
expectAltAz a = Expect.all [ \c -> Expect.within (Absolute 0.01) a.alt c.alt,
                \c -> Expect.within (Absolute 0.01) a.az c.az]
