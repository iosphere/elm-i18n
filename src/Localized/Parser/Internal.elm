module Localized.Parser.Internal exposing (..)

import List.Extra as List
import Localized
import Regex exposing (Regex)


regexStringDeclarations : Regex
regexStringDeclarations =
    Regex.regex "([A-Za-z][A-Za-z0-9]*)\\s+:\\s+(.*)String"


regexSimpleStringValue : String -> Regex
regexSimpleStringValue key =
    Regex.regex (key ++ "[\\s|\\n]*=[\\s|\\n]*\"(.*)\"")


regexStringComment : String -> Regex
regexStringComment key =
    Regex.regex ("\\{-\\| ([^-}]*) -\\}\\n" ++ key ++ "\\s+:")


regexFormats : String -> Regex
regexFormats key =
    -- myFormat ([^=\n]*) =[\s\n]((?:.+\r?\n)+(?=(\r?\n)?))
    (key ++ " ([^=\\n]*)=[\\s\\n]((?:.+\\r?\\n)+(?=(\\r?\\n)?))")
        |> Regex.regex


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


findStaticElementForKey : String -> String -> Maybe Localized.Element
findStaticElementForKey source key =
    let
        maybeValue =
            Regex.find (Regex.AtMost 1) (regexSimpleStringValue key) source
                |> List.head
                |> submatchAt 0
    in
        case maybeValue of
            Just value ->
                Localized.Static key (findComment source key) value
                    |> Localized.ElementStatic
                    |> Just

            Nothing ->
                Nothing


findFormatElementForKey : String -> String -> Maybe Localized.Element
findFormatElementForKey source key =
    let
        regex =
            regexFormats key

        match =
            Regex.find (Regex.AtMost 1) regex source
                |> List.head

        placeholders =
            case submatchAt 0 match of
                Just placeholderString ->
                    String.split " " placeholderString
                        |> trimmedStrings
                        |> Debug.log "placeholders"

                Nothing ->
                    []

        content =
            case submatchAt 1 match of
                Just placeholderString ->
                    String.split "++" placeholderString
                        |> trimmedStrings
                        |> List.map formatComponentFromString
                        |> Debug.log "content"

                Nothing ->
                    []
    in
        case placeholders of
            [] ->
                Nothing

            placeholderList ->
                Localized.Format key (findComment source key) placeholderList content
                    |> Localized.ElementFormat
                    |> Just


findComment : String -> String -> String
findComment source key =
    let
        match =
            Regex.find (Regex.AtMost 1) (regexStringComment key) source
                |> List.head
    in
        submatchAt 0 match
            |> Maybe.withDefault ""


formatComponentFromString : String -> Localized.FormatComponent
formatComponentFromString value =
    if String.endsWith "\"" value && String.startsWith "\"" value then
        -- Remove quotes from value
        String.dropLeft 1 value
            |> String.dropRight 1
            |> Localized.FormatComponentStatic
    else
        Localized.FormatComponentPlaceholder value


trimmedStrings : List String -> List String
trimmedStrings stringList =
    List.map String.trim stringList
        |> List.filter (String.isEmpty >> not)


submatchAt : Int -> Maybe Regex.Match -> Maybe String
submatchAt index match =
    match
        |> Maybe.map (.submatches >> List.getAt index)
        |> Maybe.withDefault Nothing
        |> Maybe.withDefault Nothing
