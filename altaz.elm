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

type alias Field = { ra: Float, dec: Float, age: Float}

type alias RaDec = { ra: Float, dec: Float}

type alias AltAz = { alt: Float, az: Float}

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
    spec = PolarSpec 98 98 50 50
    mapping = makePolarMapping spec
  in
    Html.div [ HtmlAttr.style [ ("backgroundColor", "black"),
                                ("height", "100%"), ("padding", "1em") ] ] [
    svg [ viewBox "0 0 100 100", width "500px" ]
        [
         polarGrid mapping,
         fieldRect (skyToAltAz (RaDec 3.0 32.0) model.lst) mapping
        ]
      ]


-- LST in radians
-- Obviously obs_lat should not be here
skyToAltAz: RaDec -> Float -> AltAz
skyToAltAz coord lst =
  let
    obs_lat = degrees 32.0
    hour_angle = lst - (degrees 3.0)
    -- sin(ALT) = sin(DEC)*sin(LAT)+cos(DEC)*cos(LAT)*cos(HA)
    sin_alt = ((sin (degrees coord.dec)) * (sin obs_lat) +
      (cos (degrees coord.dec)) * (cos obs_lat) * (cos hour_angle))
    alt = asin sin_alt
    cos_a = (sin (degrees coord.dec) - (sin alt)*(sin obs_lat))/((cos alt)*(cos obs_lat))
    az = if sin hour_angle < 0 then acos cos_a else 2*pi - (acos cos_a)
  in
    AltAz alt az

fieldRect: AltAz -> PolarMapping -> Svg msg
fieldRect coord mapping =
  let
    (plot_x, plot_y) = mapping coord.az (pi/2 - coord.alt)
  in
    svg [] [
      rect [x (toString plot_x), y (toString plot_y),
            width "5", height "5", fill "orange" ] []
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
  in
   svg [] [
       alt_gridline (pi/2.0),
       alt_gridline (pi/4.0),
       rad_gridline (0),
       rad_gridline (pi/2.0),
       rad_gridline (pi),
       rad_gridline (3*pi/2.0)
       ]
