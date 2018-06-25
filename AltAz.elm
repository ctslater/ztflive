
module AltAz exposing (altAzPlot, PolarSpec, makePolarMapping)

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)

import Coordinates exposing (RaDec, AltAz, skyToAltAz)

type alias PolarSpec = {width: Float, height: Float,
                        cx: Float, cy: Float }

type alias PolarMapping = Float -> Float -> (Float, Float)

altAzPlot: List(RaDec a) -> Float -> Float -> PolarMapping -> Html msg
altAzPlot fields latitude lst mapping =
  svg [ viewBox "0 0 100 100", width "500px" ] [
     polarGrid mapping,
     rectsFromModel fields latitude lst mapping
  ]

rectsFromModel: List(RaDec a) -> Float -> Float -> PolarMapping -> Svg msg
rectsFromModel fields latitude lst mapping =
  svg [] (List.map (\radec -> fieldRect (skyToAltAz radec latitude lst) mapping) fields)

fieldRect: AltAz -> PolarMapping -> Svg msg
fieldRect coord mapping =
  let
    (plot_x, plot_y) = mapping coord.az (pi/2 - coord.alt)
  in
    rect [x (toString plot_x), y (toString plot_y),
          width "5", height "5", fill "orange" ] []

-- Theta is the azimuth in radians, clockwise from zero at the top
-- Phi is the polar angle, pi/2 at the outer gridline.
makePolarMapping: PolarSpec -> Float -> Float -> (Float, Float)
makePolarMapping spec theta phi =
  let
    delta_width = spec.width/2.0
    delta_height = spec.height/2.0
  in
    (spec.cx - phi/(pi/2.0) * delta_width * sin(theta),
     spec.cy - phi/(pi/2.0) * delta_height * cos(theta))

polarGrid: PolarMapping -> Svg msg
polarGrid mapping =
  let
    (float_cx, float_cy) = mapping 0.0 0.0
    this_cx = toString float_cx
    this_cy = toString float_cy

    alt_gridline radius =
      let
        (x, y) = mapping pi radius
        pixel_radius = y - float_cy
      in
        circle [ cx this_cx, cy this_cy, r (toString pixel_radius),
                 stroke "white", fill "none", strokeWidth "0.3" ] []

    rad_gridline angle =
      let
        (x2_val, y2_val) = mapping angle (pi/2.0)
      in
         line [ x1 this_cx, y1 this_cy,
                x2 (toString x2_val), y2 (toString y2_val),
                stroke "#023963", strokeWidth "0.3" ] []
    text_label angle label =
      let
        (x_val, y_val) = mapping angle (0.93 * pi/2.0)
      in
         text_ [ x (toString x_val), y (toString y_val),
                 alignmentBaseline "middle",
                 stroke "white", fontSize "4", strokeWidth "0.1"] [text label]
  in
   svg [] [
       alt_gridline (pi/2.0),
       alt_gridline (pi/4.0),
       rad_gridline (0),
       rad_gridline (pi/2.0),
       rad_gridline (pi),
       rad_gridline (3*pi/2.0),
       text_label 0.0 "N",
       text_label (pi/2) "E",
       text_label pi "S",
       text_label (3*pi/2) "W"
       ]
