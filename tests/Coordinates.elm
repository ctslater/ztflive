module Example exposing (..)

import Expect exposing (Expectation, FloatingPointTolerance(Absolute) )
import Fuzz exposing (Fuzzer, int, list, string)
import Test exposing (..)

import Coordinates exposing (RaDec, AltAz, skyToAltAz)

-- skyToAltAz: RaDec a -> Float -> AltAz
suite : Test
suite =
    describe "The Coordinates module "
        [ test "Converts RaDec" <|
            \_ -> expectAltAz (AltAz 12.2 2.2) (skyToAltAz {ra = 12.3, dec = 23.1} 11.1)

        ]

expectAltAz: AltAz -> AltAz -> Expectation 
expectAltAz a = Expect.all [ \c -> Expect.within (Absolute 0.01) a.alt c.alt,
                \c -> Expect.within (Absolute 0.01) a.az c.az]

--    ((b.alt |> Expect.within (Absolute 0.01) a.alt) &&
--expectAltAz a b = ((b.alt |> Expect.within (Absolute 0.01) a.alt) &&
--                                (b.az |> Expect.within (Absolute 0.01) a.az))