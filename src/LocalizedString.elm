module LocalizedString exposing (..)

import Regex exposing (Regex)
import List.Extra as List


type alias LocalizedString =
    { key : String
    , comment : String
    , value : String
    }


regexStringDeclarations : Regex
regexStringDeclarations =
    Regex.regex "([A-Za-z][A-Za-z0-9]*)\\s+:\\s+(.*)String"


regexStringValue : String -> Regex
regexStringValue key =
    Regex.regex (key ++ "[\\s|\\n]*=\\s*\"(.*)\"")


regexStringComment : String -> Regex
regexStringComment key =
    Regex.regex ("\\{-\\| ([^-}]*) -\\}\\n" ++ key ++ "\\s+:")


parse : String -> List LocalizedString
parse source =
    let
        stringDeclarations =
            Regex.find Regex.All regexStringDeclarations source
                |> Debug.log "stringDeclarations"

        simpleStringKeys =
            stringDeclarations
                |> List.filterMap
                    (\match ->
                        if (List.getAt 1 match.submatches) == Just (Just "") then
                            List.head match.submatches |> Maybe.withDefault Nothing
                        else
                            Nothing
                    )
    in
        List.map (\key -> LocalizedString key (findComment source key) (findValueForKey source key)) simpleStringKeys


findValueForKey : String -> String -> String
findValueForKey source key =
    let
        match =
            Regex.find (Regex.AtMost 1) (regexStringValue key) source
                |> List.head
    in
        match
            |> Maybe.map (.submatches >> List.head)
            |> Maybe.withDefault Nothing
            |> Maybe.withDefault Nothing
            |> Maybe.withDefault ""


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
