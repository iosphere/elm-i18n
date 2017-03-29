module PO.Import exposing (generate)

import Dict exposing (Dict)
import Localized exposing (FormatComponent)
import PO.Import.Internal exposing (..)


generate : String -> List ( String, List Localized.Element )
generate poString =
    let
        keysInModules =
            keys poString
    in
        List.map
            (\( moduleName, keysInModule ) ->
                generateModule poString moduleName keysInModule
                    |> (,) moduleName
            )
            keysInModules


generateModule : String -> String -> List String -> List Localized.Element
generateModule poString moduleName allKeys =
    let
        fullComments =
            poComments poString moduleName allKeys

        fullCommentForKey key =
            Dict.get key fullComments |> Maybe.withDefault ""

        allValues =
            values poString moduleName allKeys

        valueForKey key =
            Dict.get key allValues |> Maybe.withDefault ""
    in
        List.map
            (\key ->
                element poString moduleName key (valueForKey key) (fullCommentForKey key)
            )
            allKeys
