module CSV.Export exposing (generate)

{-| The CSV export generates CSV from a list of localized elements
(Localized.Element).

@docs generate
-}

import CSV.Template
import Localized


{-| Generate a CSV string from a list of localized elements (Localized.Element).
You will usually have generated that list from a Localized.Parser that parsed
Elm source code into a list of localized elements:

    Localized.Parser.parse source
        |> CSV.Export.generate

-}
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
        |> flip String.append "\n"


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
