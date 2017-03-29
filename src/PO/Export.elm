module PO.Export exposing (generate)

import Localized
import PO.Template


generate : List Localized.Element -> String
generate elements =
    List.map line elements
        |> String.join "\n\n"
        |> flip String.append "\n"


line : Localized.Element -> String
line element =
    case element of
        Localized.ElementStatic static ->
            commentLine static.comment
                ++ "\n"
                ++ identifier static.moduleName static.key
                ++ "\n"
                ++ staticElement static.value

        Localized.ElementFormat format ->
            commentLine format.comment
                ++ "\n"
                ++ commentLine ("i18n: placeholders: " ++ String.join " " format.placeholders)
                ++ "\n"
                ++ identifier format.moduleName format.key
                ++ "\n"
                ++ ("msgstr " ++ formatElement format.components)


commentLine : String -> String
commentLine comment =
    String.split "\n" comment
        |> String.join "\n#. "
        |> String.append "#. "
        |> String.trim


identifier : String -> String -> String
identifier modulename key =
    "msgid \"" ++ modulename ++ "." ++ key ++ "\""


staticElement : String -> String
staticElement value =
    "msgstr " ++ toString value


formatElement : List Localized.FormatComponent -> String
formatElement list =
    list
        |> List.map
            (\element ->
                case element of
                    Localized.FormatComponentPlaceholder placeholder ->
                        PO.Template.placeholder placeholder

                    Localized.FormatComponentStatic string ->
                        string
            )
        |> String.join ""
        |> toString
