module PO.Import.Internal
    exposing
        ( element
        , keys
        , placeholdersFromPoComment
        , placeholdersInValue
        , poComments
        , values
        )

import Dict exposing (Dict)
import Localized exposing (..)
import Regex exposing (Regex)
import Set
import String.Extra as String
import Utils.Regex
import PO.Template


element : ModuleName -> Key -> Value -> Comment -> Element
element moduleName key value fullComment =
    let
        comment =
            commentFromPoComment fullComment

        placeholdersV =
            placeholdersInValue value

        placeholdersC =
            placeholdersFromPoComment fullComment

        placeholders =
            if placeholdersC /= [] then
                -- It is best if we find the placeholders in the comment as this guarantees the order.
                placeholdersC
            else if placeholdersV /= [] then
                placeholdersV
                    |> Debug.log "Did not find placeholder list in comment using placeholders found in msgstr instead. Order might be wrong."
            else
                []

        unquotedValue =
            String.unquote value

        meta =
            { moduleName = moduleName
            , key = key
            , comment = comment
            }
    in
        if List.isEmpty placeholders then
            ElementStatic
                { meta = meta
                , value = unquotedValue
                }
        else
            ElementFormat
                { meta = meta
                , placeholders = placeholders
                , components = formatComponentsFromValue unquotedValue placeholders
                }



---- KEYS


fullKey : ModuleName -> Key -> String
fullKey moduleName key =
    moduleName ++ "." ++ key


{-| Extract a list of all localization keys per module from a PO string file's
contents.
-}
keys : String -> List ( ModuleName, List String )
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



---- COMMENTS


{-| Extract a the full comments (including the leading `#`) from a PO string
file, for all given keys in a module. The dict will contain use the localized
key for key and the value will be the multiline comment.
-}
poComments : String -> ModuleName -> List Key -> Dict Key String
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


commentFromPoComment : String -> Comment
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


{-| Extracts placeholder definitions from a PO comment. This is mainly supported
for our own exports where we write placeholders into the comment using the
following format:

    #. i18n: placeholders: placeh1, placeh2

-}
placeholdersFromPoComment : String -> List Placeholder
placeholdersFromPoComment poComment =
    let
        placeholdersPrefix =
            " " ++ PO.Template.placeholderCommentPrefix
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



---- VALUES


{-| Extract all values for a module and a given list of keys from a PO file.
The dict will reference the value by its localization key.
-}
values : String -> ModuleName -> List Key -> Dict Key Value
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


{-| Finds all placeholders in a localized value. This is useful if the
placeholder definition is missing form the comment, but ma lead to issues with
sortine. For this reason, we only use this as a fallback an log an error.
-}
placeholdersInValue : Value -> List Placeholder
placeholdersInValue value =
    Regex.find Regex.All regexForPlaceholder value
        |> List.filterMap (\match -> Utils.Regex.submatchAt 0 (Just match))


formatComponentsFromValue : Value -> List Placeholder -> List FormatComponent
formatComponentsFromValue value placeholders =
    findPlaceholdersInStaticComponents [ FormatComponentStatic value ] placeholders


findPlaceholdersInStaticComponents : List FormatComponent -> List Placeholder -> List FormatComponent
findPlaceholdersInStaticComponents components placeholders =
    case List.head placeholders of
        Nothing ->
            components

        Just nextPlaceholder ->
            let
                subcomps =
                    List.map
                        (\component ->
                            case component of
                                FormatComponentPlaceholder _ ->
                                    [ component ]

                                FormatComponentStatic value ->
                                    let
                                        subComponents =
                                            String.split (PO.Template.placeholder nextPlaceholder) value
                                                |> List.map FormatComponentStatic
                                                |> List.intersperse (FormatComponentPlaceholder nextPlaceholder)
                                                |> List.filter (isEmptyFormatComponent >> not)
                                    in
                                        subComponents
                        )
                        components
                        |> List.concat
            in
                findPlaceholdersInStaticComponents subcomps (List.tail placeholders |> Maybe.withDefault [])



---- REGEX


regexComments : Key -> Regex
regexComments key =
    -- Find all lines preceeding `msgid "key"` that start with `#.`
    Regex.regex ("((?:#\\.[^\\n]*\\n)*)msgid " ++ toString key)


regexForValue : Key -> Regex
regexForValue key =
    -- Find all lines succeeding `msgid "key" \nmsgstr` until the two successive white lines
    Regex.regex
        ("msgid \"" ++ key ++ "\"\nmsgstr ((?:.+\\r?\\n)+(?=(\\r?\\n)?))")


regexForPlaceholder : Regex
regexForPlaceholder =
    -- Find all placeholders in a value
    Regex.regex "%\\(([^\\)]+)\\)s"


regexMsgId : Regex
regexMsgId =
    -- Find all msgids split into the last component (separated by dot) and
    -- the first part which is the module.
    Regex.regex "msgid \"([^\"]+)\\.([^\"]+)\""
