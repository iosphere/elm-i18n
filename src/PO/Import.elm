module PO.Import exposing (generate, keys, placeholdersInValue, placeholdersFromPoComment)

import Dict exposing (Dict)
import Localized exposing (FormatComponent)
import Regex exposing (Regex)
import Set
import Utils.Regex


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


element : String -> String -> String -> String -> String -> Localized.Element
element poString moduleName key value fullComment =
    let
        comment =
            commentFromPoComment fullComment

        placeholdersV =
            placeholdersInValue value

        placeholdersC =
            placeholdersFromPoComment fullComment

        placeholders =
            if placeholdersC /= [] then
                placeholdersC
            else if placeholdersV /= [] then
                placeholdersV
                    |> Debug.log "Did not find placeholder list in comment using placeholders found in msgstr instead."
            else
                []
    in
        if List.isEmpty placeholders then
            Localized.ElementStatic
                { moduleName = moduleName
                , key = key
                , comment = comment
                , value =
                    -- Remove quotes from value
                    String.dropLeft 1 value |> String.dropRight 1
                }
        else
            Localized.ElementFormat
                { moduleName = moduleName
                , key = key
                , comment = comment
                , placeholders = placeholders
                , components = formatComponentsFromValue value placeholders
                }


placeholdersInValue : String -> List String
placeholdersInValue value =
    Regex.find Regex.All regexForPlaceholder value
        |> List.filterMap (\match -> Utils.Regex.submatchAt 0 (Just match))


fullKey : String -> String -> String
fullKey moduleName key =
    moduleName ++ "." ++ key


poComments : String -> String -> List String -> Dict String String
poComments poString moduleName allKeys =
    allKeys
        |> List.map
            (\key ->
                Regex.find (Regex.AtMost 1) (regexComments (fullKey moduleName key)) poString
                    |> List.head
                    |> Utils.Regex.submatchAt 0
                    |> Maybe.withDefault ""
                    |> (,) key
            )
        |> Dict.fromList


commentFromPoComment : String -> String
commentFromPoComment poComment =
    String.trim poComment
        |> String.split "#."
        |> List.filterMap
            (\line ->
                if String.startsWith " i18n:" line then
                    Nothing
                else
                    Just (String.trim line)
            )
        |> String.join "\n"
        |> String.trim


placeholdersFromPoComment : String -> List String
placeholdersFromPoComment poComment =
    let
        placeholdersPrefix =
            " i18n: placeholders: "
    in
        String.trim poComment
            |> String.split "#."
            |> List.filterMap
                (\line ->
                    if String.startsWith placeholdersPrefix line then
                        Just
                            (String.dropLeft (String.length placeholdersPrefix) line
                                |> String.trim
                            )
                    else
                        Nothing
                )
            |> List.head
            |> Maybe.map (String.split " ")
            |> Maybe.withDefault []


values : String -> String -> List String -> Dict String String
values poString moduleName allKeys =
    allKeys
        |> List.map
            (\key ->
                Regex.find (Regex.AtMost 1) (regexForValue (fullKey moduleName key)) poString
                    |> List.head
                    |> Utils.Regex.submatchAt 0
                    |> Maybe.withDefault ""
                    |> String.trim
                    |> (,) key
            )
        |> Dict.fromList


formatComponentsFromValue : String -> List String -> List Localized.FormatComponent
formatComponentsFromValue value placeholders =
    let
        _ =
            Debug.log "value" value

        unqoutedValue =
            String.dropLeft 1 value |> String.dropRight 1

        initial =
            Localized.FormatComponentStatic unqoutedValue
    in
        [ initial ]


keys : String -> List ( String, List String )
keys poString =
    let
        matches =
            Regex.find Regex.All regexMsgId poString

        moduleAndKeys =
            List.map (\match -> ( Utils.Regex.submatchAt 0 (Just match), Utils.Regex.submatchAt 1 (Just match) )) matches
                |> List.filterMap
                    (\maybeTuple ->
                        case maybeTuple of
                            ( Just moduleName, Just key ) ->
                                Just ( moduleName, key )

                            _ ->
                                Nothing
                    )

        modules =
            List.map Tuple.first moduleAndKeys
                |> Set.fromList
                |> Set.toList
    in
        List.map
            (\modulename ->
                List.filterMap
                    (\( someModule, key ) ->
                        if modulename == someModule then
                            Just key
                        else
                            Nothing
                    )
                    moduleAndKeys
                    |> (,) modulename
            )
            modules


regexComments : String -> Regex
regexComments key =
    Regex.regex ("((?:#\\.[^\\n]*\\n)*)msgid " ++ toString key)


regexForValue : String -> Regex
regexForValue key =
    Regex.regex
        ("msgid \"" ++ key ++ "\"\nmsgstr ((?:.+\\r?\\n)+(?=(\\r?\\n)?))")


regexForPlaceholder : Regex
regexForPlaceholder =
    Regex.regex "%\\(([^\\)]+)\\)s"


regexMsgId : Regex
regexMsgId =
    Regex.regex "msgid \"([^\"]+)\\.([^\"]+)\""
