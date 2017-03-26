module CSV.Import exposing (generate)

import Csv
import Regex exposing (Regex)


generate : String -> String
generate csv =
    case Csv.parse csv of
        Result.Ok lines ->
            List.filterMap fromLine lines.records
                |> String.join "\n\n"

        Result.Err err ->
            Debug.log "Could not parse CSV" err
                |> always ""


fromLine : List String -> Maybe String
fromLine columns =
    case columns of
        [ key, comment, placeholders, value ] ->
            Just (code key comment placeholders value)

        _ ->
            Nothing


regexPlaceholder : Regex
regexPlaceholder =
    Regex.regex "\\{\\{([^\\}]*)\\}\\}"


regexTrailingEmptyString : Regex
regexTrailingEmptyString =
    Regex.regex "[\\s\\n]*\\+\\+\\s*\"\""


code : String -> String -> String -> String -> String
code key comment placeholderString value =
    let
        commentCode =
            if String.isEmpty comment then
                ""
            else
                "{-| " ++ comment ++ " -}\n"

        tab =
            "    "

        valueWithPlaceholders =
            Regex.replace Regex.All
                regexPlaceholder
                (\match ->
                    let
                        placeholder =
                            List.head match.submatches
                                |> Maybe.withDefault Nothing
                                |> Maybe.withDefault "unknown"
                    in
                        "\"\n"
                            ++ (tab ++ tab)
                            ++ ("++ " ++ placeholder)
                            ++ (tab ++ tab ++ "++ \"")
                )
                value

        -- clean up trailing `++ ""`
        implementation =
            ("\"" ++ valueWithPlaceholders ++ "\"")
                |> Regex.replace Regex.All regexTrailingEmptyString (always "")

        placeholders =
            String.split " " placeholderString
                |> List.map String.trim
                |> List.filter (String.isEmpty >> not)

        numPlaceholders =
            List.length placeholders

        functionArgument =
            if numPlaceholders == 0 then
                ""
            else
                " " ++ String.join " " placeholders

        functionSignature =
            List.repeat numPlaceholders " -> String"
                |> String.join ""
    in
        commentCode
            ++ (key ++ " : String" ++ functionSignature ++ "\n")
            ++ (key ++ functionArgument ++ " =\n")
            ++ (tab ++ (implementation))
