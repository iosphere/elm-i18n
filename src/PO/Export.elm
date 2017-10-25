module PO.Export exposing (generate)

{-| The PO export generates PO strings from a list of localized elements
(Localized.Element). For more information about the PO Localized.Format visit:
<https://www.gnu.org/savannah-checkouts/gnu/gettext/manual/html_node/PO-Files.html>

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
            commentLine static.meta.comment
                ++ "\n"
                ++ identifier static.meta.moduleName static.meta.key
                ++ "\n"
                ++ staticElement static.value

        Localized.ElementFormat format ->
            commentLine format.meta.comment
                ++ "\n"
                ++ commentLine (PO.Template.placeholderCommentPrefix ++ String.join " " format.placeholders)
                ++ "\n"
                ++ identifier format.meta.moduleName format.meta.key
                ++ "\n"
                ++ ("msgstr " ++ formatElement format.components)


commentLine : Localized.Comment -> String
commentLine comment =
    String.split "\n" comment
        |> String.join "\n#. "
        |> String.append "#. "
        |> String.trim


identifier : Localized.ModuleName -> Localized.Key -> String
identifier modulename key =
    "msgid \"" ++ modulename ++ "." ++ key ++ "\""


staticElement : Localized.Value -> String
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
