module Localized.Parser.Internal exposing (..)

import List.Extra as List
import Localized exposing (..)
import Regex exposing (Regex)
import Utils.Regex as Utils


regexFindModuleName : Regex
regexFindModuleName =
    Regex.regex "module ([^\\s]*) exposing"


regexStringDeclarations : Regex
regexStringDeclarations =
    Regex.regex "([A-Za-z][A-Za-z0-9]*)\\s+:\\s+(.*)String"


regexSimpleStringValue : String -> Regex
regexSimpleStringValue key =
    Regex.regex (key ++ "[\\s|\\n]*=[\\s|\\n]*\"(.*)\"")


regexStringComment : String -> Regex
regexStringComment key =
    Regex.regex ("\\{-\\| ([^\\}]*)\\n-\\}\\n" ++ key ++ "\\s+:")


regexFormats : String -> Regex
regexFormats key =
    -- myFormat ([^=\n]*) =[\s\n]((?:.+\r?\n)+(?=(\r?\n)?))
    (key ++ " ([^=\\n]*)=[\\s\\n]((?:.+\\r?\\n)+(?=(\\r?\\n)?))")
        |> Regex.regex


findModuleName : SourceCode -> ModuleName
findModuleName source =
    Regex.find (Regex.AtMost 1) regexFindModuleName source
        |> List.head
        |> Utils.submatchAt 0
        |> Maybe.withDefault "unknown"


{-| Finds all top level string declarations, both constants (`key : String`
and functions returning strings (e.g. `fun : String -> String`).
-}
stringDeclarations : SourceCode -> List ( Key, List String )
stringDeclarations source =
    Regex.find Regex.All regexStringDeclarations source
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


findStaticElementForKey : ModuleName -> SourceCode -> Key -> Maybe Element
findStaticElementForKey moduleName source key =
    let
        maybeValue =
            Regex.find (Regex.AtMost 1) (regexSimpleStringValue key) source
                |> List.head
                |> Utils.submatchAt 0
    in
        case maybeValue of
            Just value ->
                Static (Meta moduleName key (findComment source key)) value
                    |> ElementStatic
                    |> Just

            Nothing ->
                Nothing


findFormatElementForKey : ModuleName -> SourceCode -> Key -> Maybe Element
findFormatElementForKey moduleName source key =
    let
        regex =
            regexFormats key

        match =
            Regex.find (Regex.AtMost 1) regex source
                |> List.head

        placeholders =
            case Utils.submatchAt 0 match of
                Just placeholderString ->
                    String.split " " placeholderString
                        |> trimmedStrings

                Nothing ->
                    []

        content =
            case Utils.submatchAt 1 match of
                Just placeholderString ->
                    String.split "++" placeholderString
                        |> trimmedStrings
                        |> List.map formatComponentFromString

                Nothing ->
                    []
    in
        case placeholders of
            [] ->
                Nothing

            placeholderList ->
                Format (Meta moduleName key (findComment source key)) placeholderList content
                    |> ElementFormat
                    |> Just


findComment : SourceCode -> Key -> Comment
findComment source key =
    let
        match =
            Regex.find (Regex.AtMost 1) (regexStringComment key) source
                |> List.head
    in
        Utils.submatchAt 0 match
            |> Maybe.withDefault ""


formatComponentFromString : String -> FormatComponent
formatComponentFromString value =
    if String.endsWith "\"" value && String.startsWith "\"" value then
        -- Remove quotes from value
        String.dropLeft 1 value
            |> String.dropRight 1
            |> FormatComponentStatic
    else
        FormatComponentPlaceholder value


trimmedStrings : List String -> List String
trimmedStrings stringList =
    List.map String.trim stringList
        |> List.filter (String.isEmpty >> not)
