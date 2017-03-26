module CSV.Export exposing (generate)

import Localized


generate : List Localized.Element -> String
generate elements =
    List.map line elements
        |> String.join "\n"


line : Localized.Element -> String
line element =
    case element of
        Localized.ElementStatic static ->
            static.key ++ "," ++ static.comment ++ "," ++ static.value

        Localized.ElementFormat format ->
            format.key ++ "," ++ format.comment ++ "," ++ formatString format.components


formatString : List Localized.FormatComponent -> String
formatString components =
    components
        |> List.map
            (\component ->
                case component of
                    Localized.FormatComponentStatic value ->
                        value

                    Localized.FormatComponentPlaceholder placeholder ->
                        "{{" ++ placeholder ++ "}}"
            )
        |> String.join ""
