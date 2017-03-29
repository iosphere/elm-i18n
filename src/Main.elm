port module Main exposing (main)

{-| A worker program providing and interface for the Import and Export functions
in the CSV and PO submodules.

@docs main
-}

import CSV.Export
import CSV.Import
import Json.Decode
import Localized.Parser as Localized
import Localized.Writer
import PO.Export
import PO.Import
import Platform exposing (programWithFlags)


type alias Model =
    {}


type Format
    = CSV
    | PO


type Operation
    = Export Format
    | Import Format


port exportResult : String -> Cmd msg


port importResult : List ( String, String ) -> Cmd msg


operationFromString : String -> Maybe String -> Operation
operationFromString operation formatString =
    formatFromString formatString
        |> if operation == "import" then
            Import
           else
            Export


formatFromString : Maybe String -> Format
formatFromString maybeFormat =
    let
        formatString =
            Maybe.map String.toUpper maybeFormat
    in
        if formatString == Just "PO" then
            PO
        else
            CSV


type alias Flags =
    { sources : List String
    , operation : String
    , format : Maybe String
    }


{-| A worker program providing and interface for the Import and Export functions
in the CSV and PO submodules.
-}
main : Program Flags Model Never
main =
    programWithFlags { init = init, update = update, subscriptions = always Sub.none }


init : Flags -> ( Model, Cmd Never )
init flags =
    case operationFromString flags.operation flags.format of
        Export format ->
            ( {}, operationExport flags.sources format )

        Import format ->
            ( {}, operationImport flags.sources format )


operationExport : List String -> Format -> Cmd Never
operationExport source format =
    let
        exportFunction =
            case format of
                CSV ->
                    CSV.Export.generate

                PO ->
                    PO.Export.generate

        exportValue =
            List.map Localized.parse source
                |> List.concat
                |> exportFunction
    in
        exportResult exportValue


operationImport : List String -> Format -> Cmd Never
operationImport csv format =
    let
        importFunction =
            case format of
                CSV ->
                    CSV.Import.generate

                PO ->
                    PO.Import.generate
    in
        List.head csv
            |> Maybe.withDefault ""
            |> importFunction
            |> Localized.Writer.generate
            |> List.map (Tuple.mapFirst (String.split "." >> String.join "/"))
            |> importResult


update : Never -> Model -> ( Model, Cmd Never )
update msg model =
    ( model, Cmd.none )
