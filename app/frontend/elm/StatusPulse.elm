module StatusPulse exposing (main)

import Browser
import Html exposing (Html, button, div, p, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Json.Decode as Decode


type alias Flags =
    { accountName : String
    }


type alias Model =
    { accountName : String
    , pulseCount : Int
    }


type Msg
    = Pulse


main : Program Decode.Value Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }


init : Decode.Value -> ( Model, Cmd Msg )
init flags =
    let
        decodedFlags =
            Decode.decodeValue flagsDecoder flags
                |> Result.withDefault { accountName = "Demo account" }
    in
    ( { accountName = decodedFlags.accountName, pulseCount = 0 }, Cmd.none )


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map Flags
        (Decode.field "accountName" Decode.string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Pulse ->
            ( { model | pulseCount = model.pulseCount + 1 }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "rounded-lg border border-base-300 bg-base-200 p-4" ]
        [ p [ class "text-sm font-medium" ] [ text model.accountName ]
        , div [ class "mt-3 flex items-center gap-3" ]
            [ span [ class "badge badge-success" ] [ text "Ready" ]
            , button [ class "btn btn-xs btn-outline", onClick Pulse ] [ text "Ping" ]
            ]
        , p [ class "mt-3 text-sm text-base-content/65" ]
            [ text ("Frontend pulses: " ++ String.fromInt model.pulseCount) ]
        ]
