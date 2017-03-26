port module Main exposing (main)

{-| The main module

@docs main
-}

import CSV.Export
import CSV.Import
import Json.Decode
import Localized.Parser as Localized
import Platform exposing (programWithFlags)


type alias Model =
    {}


type Msg
    = NoOp


type Operation
    = Export
    | Import


port result : String -> Cmd msg


operationFromString : String -> Operation
operationFromString operation =
    if operation == "import" then
        Import
    else
        Export


type alias Flags =
    { source : String
    , operation : String
    }


{-| Main app
-}
main : Program Flags Model Msg
main =
    programWithFlags { init = init, update = update, subscriptions = (always Sub.none) }


init : Flags -> ( Model, Cmd Msg )
init flags =
    case operationFromString flags.operation of
        Export ->
            ( {}, operationExport flags.source )

        Import ->
            ( {}, operationImport flags.source )


operationExport : String -> Cmd Msg
operationExport source =
    let
        csv =
            Localized.parse source |> CSV.Export.generate
    in
        result csv


operationImport : String -> Cmd Msg
operationImport csv =
    Debug.log "import" csv
        |> CSV.Import.generate
        |> result


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
