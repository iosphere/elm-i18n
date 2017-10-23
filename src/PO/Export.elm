module PO.Export exposing (generate)

{-| The PO export generates PO strings from a list of localized elements
(Localized.Element). For more information about the PO Format visit:
https://www.gnu.org/savannah-checkouts/gnu/gettext/manual/html_node/PO-Files.html

@docs generate
-}

import Localized exposing (..)
import PO.Template


{-| Generate a PO string from a list of localized elements (Localized.Element).
You will usually have generated that list from a Localized.Parser that parsed
Elm source code into a list of localized elements:

    Localized.Parser.parse source
        |> PO.Export.generate

-}
generate : List Element -> String
generate elements =
    List.map line elements
        |> String.join "\n\n"
        |> flip String.append "\n"


line : Element -> String
line element =
    case element of
        ElementStatic static ->
            commentLine static.meta.comment
                ++ "\n"
                ++ identifier static.meta.moduleName static.meta.key
                ++ "\n"
                ++ staticElement static.value

        ElementFormat format ->
            commentLine format.meta.comment
                ++ "\n"
                ++ commentLine (PO.Template.placeholderCommentPrefix ++ String.join " " format.placeholders)
                ++ "\n"
                ++ identifier format.meta.moduleName format.meta.key
                ++ "\n"
                ++ ("msgstr " ++ formatElement format.components)


commentLine : Comment -> String
commentLine comment =
    String.split "\n" comment
        |> String.join "\n#. "
        |> String.append "#. "
        |> String.trim


identifier : ModuleName -> Key -> String
identifier modulename key =
    "msgid \"" ++ modulename ++ "." ++ key ++ "\""


staticElement : Value -> String
staticElement value =
    "msgstr " ++ toString value


formatElement : List FormatComponent -> String
formatElement list =
    list
        |> List.map
            (\element ->
                case element of
                    FormatComponentPlaceholder placeholder ->
                        PO.Template.placeholder placeholder

                    FormatComponentStatic string ->
                        string
            )
        |> String.join ""
        |> toString
