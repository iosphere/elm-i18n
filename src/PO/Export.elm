module PO.Export exposing (generate)

{-| The PO export generates PO strings from a list of localized elements
(Localized.Element). For more information about the PO Format visit:
https://www.gnu.org/savannah-checkouts/gnu/gettext/manual/html_node/PO-Files.html

@docs generate
-}

import Localized
import PO.Template


{-| Generate a PO string from a list of localized elements (Localized.Element).
You will usually have generated that list from a Localized.Parser that parsed
Elm source code into a list of localized elements:

    Localized.Parser.parse source
        |> PO.Export.generate

-}
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
