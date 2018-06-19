
import Html exposing (Html, text)
import Html.Attributes as HtmlAttr
import Html.Events exposing (onClick)
import List
import Dict
import Http
import Json.Decode
import Time exposing (Time)

import AltAz exposing (altAzPlot, PolarSpec, makePolarMapping)

main =
  Html.program
    {
    init = init ,
    view = view,
    update = update,
    subscriptions = subscriptions
    }

-- Init

init: (Model, Cmd Msg)
init =
  (
  Model 0.50 Dict.empty,
  sendGetFieldReq)

-- MODEL

type alias Model = { lst:  Float, fields: Dict.Dict String Field }

type alias Field = { ra: Float, dec: Float, alerts: String, visit: String}

subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every Time.minute Tick

-- UPDATE

type Msg = Reset | IncLST | DecLST | Tick Time
          | GetFields | VisitsUpdate (Result Http.Error (List Field))

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Reset -> (model, Cmd.none)
    IncLST -> ({ model | lst = model.lst + ((2 * pi)/24) }, Cmd.none)
    DecLST -> ({ model | lst = model.lst - ((2 * pi)/24) }, Cmd.none)
    Tick _ -> (model, sendGetFieldReq)
    GetFields -> (model, sendGetFieldReq)
    VisitsUpdate (Ok newFields) -> ({ model | fields = addUpdatedFields model.fields newFields }, Cmd.none)
    VisitsUpdate (Err _) -> (model, Cmd.none)


addUpdatedFields: Dict.Dict String Field -> List (Field) -> Dict.Dict String Field
addUpdatedFields originalFields newFields = 
  let
    fieldsWithVisitIDs = List.map ( \a -> (a.visit, a) ) newFields
    newFieldDictionary = Dict.fromList fieldsWithVisitIDs
  in
    Dict.union newFieldDictionary originalFields

fieldDecoder: Json.Decode.Decoder Field
fieldDecoder = Json.Decode.map4 Field (Json.Decode.field "RA" Json.Decode.float)
                                      (Json.Decode.field "Dec" Json.Decode.float)
                                      (Json.Decode.field "alertcount" Json.Decode.string)
                                      (Json.Decode.field "visit" Json.Decode.string)

sendGetFieldReq: Cmd Msg
sendGetFieldReq =
  let
    url = "/visits"
    request = Http.get url (Json.Decode.list fieldDecoder)
  in
    Http.send VisitsUpdate request

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
      altAzPlot (Dict.values model.fields) model.lst mapping,
      lstControls model,
      -- Html.button [ onClick GetFields ] [ text "Get Fields" ],
      alertsTable model
    ]

alertsTableRow: Field -> Html msg
alertsTableRow field =
    Html.tr [] [
      Html.td [] [text field.visit],
      -- Html.td [] [text "01:03"],
      Html.td [] [text (toString field.ra)],
      Html.td [] [text (toString field.dec)],
      Html.td [] [text field.alerts]
    ]


alertsTable : Model -> Html Msg
alertsTable model =
  Html.div [] [
    Html.table [HtmlAttr.style [("border-spacing", "0.5em")]] ([
      Html.thead [] [
        Html.th [] [text "Visit"],
        -- Html.th [] [text "Time (UTC)"],
        Html.th [] [text "Ra"],
        Html.th [] [text "Dec"],
        Html.th [] [text "# of Alerts"]
      ]
    ] ++ List.map alertsTableRow (Dict.values model.fields)
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
