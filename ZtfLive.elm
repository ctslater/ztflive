
import Html exposing (Html, text)
import Html.Attributes as HtmlAttr
import Html.Events exposing (onClick)
import List
import Http
import Json.Decode

import AltAz exposing (altAzPlot, PolarSpec, makePolarMapping)
import Coordinates exposing (RaDec, AltAz)

main =
  Html.program
    {
    init = init ,
--    model = model,
    view = view,
    update = update,
    subscriptions = subscriptions
    }

-- Init

init: (Model, Cmd Msg)
init =
  (
  Model 0.0 [],
  sendGetFieldReq)

-- MODEL

type alias Model = { lst:  Float, fields: List(Field) }

type alias Field = { ra: Float, dec: Float, alerts: String}

--model : Model
--model =
--  { lst = 0.0,
--    fields = [ RaDec 3.0 32.0,
--               RaDec 5.0 44.0] }


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

-- UPDATE

type Msg = Reset | IncLST | DecLST
          | GetFields | VisitsUpdate (Result Http.Error (List Field))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Reset -> (model, Cmd.none)
    IncLST -> ({ model | lst = model.lst + ((2 * pi)/24) }, Cmd.none)
    DecLST -> ({ model | lst = model.lst - ((2 * pi)/24) }, Cmd.none)
    GetFields -> (model, sendGetFieldReq)
    VisitsUpdate (Ok fields) -> ({ model | fields = fields}, Cmd.none)
    VisitsUpdate (Err _) -> (model, Cmd.none)

fieldDecoder: Json.Decode.Decoder Field
fieldDecoder = Json.Decode.map3 Field (Json.Decode.field "RA" Json.Decode.float)
                                      (Json.Decode.field "Dec" Json.Decode.float)
                                      (Json.Decode.field "alertcount" Json.Decode.string)

addFields: String -> List Field
addFields dataString = 
  case Json.Decode.decodeString (Json.Decode.list fieldDecoder) dataString of
  Err _ -> []
  Ok newFields -> newFields

sendGetFieldReq: Cmd Msg
sendGetFieldReq =
  let
    url = "/visits"
    request = Http.get url (Json.Decode.list fieldDecoder)
  in
    Http.send VisitsUpdate request

-- {"Dec": 40.55, "RA": 243.95089, "alertcount": "91", "field": "722",
-- "firstseen": "2018-06-13T16:04:53.464187", "lastseen":
-- "2018-06-13T16:04:56.299064", "visit": "20180612261030"}


-- VIEW

view : Model -> Html Msg
view model =
  let
    spec = PolarSpec 98 98 50 50
    mapping = makePolarMapping spec
  in
    Html.div [ HtmlAttr.style [ ("backgroundColor", "black"),
                                ("color", "white"),
                                ("height", "100vh"), ("padding", "1em") ] ] [
      altAzPlot model.fields model.lst mapping,
      lstControls model,
      Html.button [ onClick GetFields ] [ text "Get Fields" ],
      alertsTable model
    ]

alertsTableRow: Field -> Html msg
alertsTableRow field =
    Html.tr [] [
      Html.td [] [text "1032432"],
      Html.td [] [text "01:03"],
      Html.td [] [text (toString field.ra)],
      Html.td [] [text (toString field.dec)],
      Html.td [] [text field.alerts]
    ]


alertsTable : Model -> Html Msg
alertsTable model =
  Html.div [] [
    Html.table [] ([
      Html.thead [] [
        Html.th [] [text "Visit"],
        Html.th [] [text "Time (UTC)"],
        Html.th [] [text "Ra"],
        Html.th [] [text "Dec"],
        Html.th [] [text "# of Alerts"]
      ]
    ] ++ List.map alertsTableRow model.fields
    )
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
