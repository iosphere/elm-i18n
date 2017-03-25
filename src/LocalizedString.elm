module LocalizedString exposing (..)

import Dict exposing (Dict)
import List.Extra as List
import Regex exposing (Regex)


type LocalizedElement
    = Simple LocalizedString
    | Format LocalizedFormat


type alias LocalizedString =
    { key : String
    , comment : String
    , value : String
    }


type FormatString
    = Value String
    | Placeholder String


type alias LocalizedFormat =
    { key : String
    , comment : String
    , placeholders : List String
    , value : List FormatString
    }


regexStringDeclarations : Regex
regexStringDeclarations =
    Regex.regex "([A-Za-z][A-Za-z0-9]*)\\s+:\\s+(.*)String"


regexSimpleStringValue : String -> Regex
regexSimpleStringValue key =
    Regex.regex (key ++ "[\\s|\\n]*=[\\s|\\n]*\"(.*)\"")


regexStringComment : String -> Regex
regexStringComment key =
    Regex.regex ("\\{-\\| ([^-}]*) -\\}\\n" ++ key ++ "\\s+:")


parse : String -> List LocalizedElement
parse source =
    let
        stringKeysAndParameters =
            stringDeclarations source
                |> Debug.log "declarations"
    in
        List.filterMap
            (\( key, params ) ->
                findSimpleElementForKey source key
            )
            stringKeysAndParameters


{-| Finds all top level string declarations, both constants (`key : String`
and functions returning strings (e.g. `fun : String -> String`).
-}
stringDeclarations : String -> List ( String, List String )
stringDeclarations source =
    let
        stringDeclarations =
            Regex.find Regex.All regexStringDeclarations source
    in
        stringDeclarations
            |> List.filterMap
                (\match ->
                    -- The submatches contain the key (at head)
                    -- and the parameters as string (or empty) at index 1.
                    case ( List.head match.submatches, List.getAt 1 match.submatches ) of
                        ( Just (Just key), Just (Just parametersString) ) ->
                            let
                                parameters =
                                    String.split " -> " parametersString
                                        |> List.filter (String.isEmpty >> not)
                            in
                                Just ( key, parameters )

                        _ ->
                            Nothing
                )


findSimpleElementForKey : String -> String -> Maybe LocalizedElement
findSimpleElementForKey source key =
    let
        maybeValue =
            Regex.find (Regex.AtMost 1) (regexSimpleStringValue key) source
                |> List.head
                |> Maybe.map (.submatches >> List.head)
                |> Maybe.withDefault Nothing
                |> Maybe.withDefault Nothing
    in
        case maybeValue of
            Just value ->
                LocalizedString key (findComment source key) value
                    |> Simple
                    |> Just

            Nothing ->
                Nothing


findComment : String -> String -> String
findComment source key =
    let
        match =
            Regex.find (Regex.AtMost 1) (regexStringComment key) source
                |> List.head
    in
        match
            |> Maybe.map (.submatches >> List.head)
            |> Maybe.withDefault Nothing
            |> Maybe.withDefault Nothing
            |> Maybe.withDefault ""
