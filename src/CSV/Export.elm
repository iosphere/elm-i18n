module CSV.Export exposing (generate)

import CSV.Template
import Localized


generate : List Localized.Element -> String
generate elements =
    List.map line elements
        |> List.map
            (\columns ->
                List.map (\column -> "\"" ++ column ++ "\"") columns
                    |> String.join ","
            )
        |> String.join "\n"
        |> String.append (CSV.Template.headers ++ "\n")
        |> (flip String.append) "\n"


line : Localized.Element -> List String
line element =
    case element of
        Localized.ElementStatic static ->
            [ static.moduleName, static.key, static.comment, "", static.value ]

        Localized.ElementFormat format ->
            [ format.moduleName, format.key, format.comment, String.join " " format.placeholders, formatString format.components ]


formatString : List Localized.FormatComponent -> String
formatString components =
    components
        |> List.map
            (\component ->
                case component of
                    Localized.FormatComponentStatic value ->
                        value

                    Localized.FormatComponentPlaceholder placeholder ->
                        CSV.Template.placeholder placeholder
            )
        |> String.join ""
