
import Html exposing (Html, text)
import Html.Attributes as HtmlAttr
import Html.Events exposing (onClick)
import List

import AltAz exposing (altAzPlot, PolarSpec, makePolarMapping)
import Coordinates exposing (RaDec, AltAz)

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

type alias Model = { lst:  Float, fields: List(RaDec) }

type alias Field = { ra: Float, dec: Float, age: Float}

model : Model
model =
  { lst = 0.0,
    fields = [ RaDec 3.0 32.0,
               RaDec 5.0 44.0] }


-- UPDATE

type Msg = Reset | IncLST | DecLST

update : Msg -> Model -> Model
update msg model =
  case msg of
    Reset -> model
    IncLST -> { model | lst = model.lst + ((2 * pi)/24) }
    DecLST -> { model | lst = model.lst - ((2 * pi)/24) }


-- VIEW

view : Model -> Html Msg
view model =
  let
    spec = PolarSpec 98 98 50 50
    mapping = makePolarMapping spec
  in
    Html.div [ HtmlAttr.style [ ("backgroundColor", "black"),
                                ("color", "white"),
                                ("height", "100%"), ("padding", "1em") ] ] [
      altAzPlot model.fields model.lst mapping,
      lstControls model,
      alertsTable model
    ]

alertsTable : Model -> Html Msg
alertsTable model =
  Html.div [] [
    Html.table [] [
      Html.thead [] [
        Html.th [] [text "Time"],
        Html.th [] [text "Ra"],
        Html.th [] [text "Dec"],
        Html.th [] [text "# of Alerts"]
      ],
      Html.tr [] [
        Html.td [] [text "Time"],
        Html.td [] [text "Ra"],
        Html.td [] [text "Dec"],
        Html.td [] [text "# of Alerts"]
      ]
    ]
  ]

lstControls: Model -> Html Msg
lstControls model =
  Html.div [] [
    Html.button [onClick DecLST] [text "<-"],
    text ("LST: " ++ (formatLST model.lst)),
    Html.button [onClick IncLST] [text "->"]
  ]

-- Incomplete, finish later
formatLST: Float -> String
formatLST lst =
  let
    hours = floor (24 * lst/(2 * pi))
  in
    toString hours ++ ":00"
