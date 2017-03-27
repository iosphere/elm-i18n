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


port exportResult : String -> Cmd msg


port importResult : List ( String, String ) -> Cmd msg


operationFromString : String -> Operation
operationFromString operation =
    if operation == "import" then
        Import
    else
        Export


type alias Flags =
    { sources : List String
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
            ( {}, operationExport flags.sources )

        Import ->
            ( {}, operationImport flags.sources )


operationExport : List String -> Cmd Msg
operationExport source =
    let
        csv =
            List.map Localized.parse source
                |> List.concat
                |> CSV.Export.generate
    in
        exportResult csv


operationImport : List String -> Cmd Msg
operationImport csv =
    List.head csv
        |> Maybe.withDefault ""
        |> CSV.Import.generate
        |> List.map (Tuple.mapFirst (String.split "." >> String.join "/"))
        |> importResult


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )
