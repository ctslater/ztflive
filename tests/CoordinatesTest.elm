module CoordinatesTest exposing (..)

import Expect exposing (Expectation, FloatingPointTolerance(Absolute) )
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)
import Date

import Coordinates exposing (RaDec, AltAz, skyToAltAz, utcToLST)

-- skyToAltAz: RaDec a -> Float -> AltAz
suite : Test
suite =
    describe "The Coordinates module "
        [ test "Converts RaDec" <|
            \_ -> expectAltAz (AltAz 12.2 2.2) (skyToAltAz {ra = 12.3, dec = 23.1} 11.1),
          test "Computes LST " <|
          \_ -> let
              test_date = "2006-01-15 21:24:37.5"
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

--    ((b.alt |> Expect.within (Absolute 0.01) a.alt) &&
--expectAltAz a b = ((b.alt |> Expect.within (Absolute 0.01) a.alt) &&
--                                (b.az |> Expect.within (Absolute 0.01) a.az))