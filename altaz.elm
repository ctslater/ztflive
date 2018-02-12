import Html exposing (Html)
import Html.Attributes as HtmlAttr
import Svg exposing (..)
import Svg.Attributes exposing (..)

main =
  Html.beginnerProgram
    {
    -- init = init ,
    model = model,
    view = view,
    update = update
     -- , subscriptions = subscriptions
    }


-- MODEL

type alias Model = { lst:  Float }

model : Model
model =
  { lst = 0.0 }


-- UPDATE

type Msg = Reset

update : Msg -> Model -> Model
update msg model =
  case msg of
    Reset -> model


-- VIEW

view : Model -> Html Msg
view model =
  let
    spec = PolarSpec 100 100 50 50
  in
    Html.div [ HtmlAttr.style [ ("backgroundColor", "black"),
                                ("height", "100%")] ] [
    svg [ viewBox "0 0 100 100", width "500px" ]
        [
         polarGrid (makePolarMapping spec),
         line [ x1 "50", y1 "50", x2 "100", y2 "50", stroke "#023963" ] []
        ]
      ]



type alias PolarSpec = {width: Float, height: Float,
                        cx: Float, cy: Float }

type alias PolarMapping = Float -> Float -> (Float, Float)

-- Theta is the azimuth in radians, clockwise from zero at the top
-- Phi is the polar angle, pi/2 at the outer gridline.
makePolarMapping: PolarSpec -> Float -> Float -> (Float, Float)
makePolarMapping spec theta phi =
  let
    delta_width = spec.width/2.0
    delta_height = spec.height/2.0
  in
    (spec.cx + phi/(pi/2.0) * delta_width * sin(theta),
     spec.cy - phi/(pi/2.0) * delta_height * cos(theta))

polarGrid: PolarMapping -> Svg msg
polarGrid mapping =
  let
    (float_cx, float_cy) = mapping 0.0 0.0
    this_cx = toString float_cx
    this_cy = toString float_cy

    alt_gridline radius =
       circle [ cx this_cx, cy this_cy, r radius, stroke "white", fill "none"] []

    rad_gridline angle =
      let
        (x2_val, y2_val) = mapping angle (pi/2.0)
      in
         line [ x1 this_cx, y1 this_cy,
                x2 (toString x2_val), y2 (toString y2_val), stroke "#023963" ] []
  in
   svg [] [
       alt_gridline "45",
       alt_gridline "25",
       rad_gridline (0),
       rad_gridline (pi/2.0),
       rad_gridline (pi),
       rad_gridline (3*pi/2.0)
       ]
