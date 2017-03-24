port module Main exposing (main)

{-| The main module

@docs main
-}

import Json.Decode
import LocalizedString exposing (LocalizedString)
import Platform exposing (programWithFlags)


type alias Model =
    {}


type Msg
    = NoOp


type alias Flags =
    { source : String }


{-| Main app
-}
main : Program Flags Model Msg
main =
    programWithFlags { init = init, update = update, subscriptions = (always Sub.none) }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        _ =
            flags.source |> LocalizedString.parse |> Debug.log "strings"
    in
        ( {}, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
