module Localized.Writer.Element exposing (..)

import Localized exposing (..)


{-| Returns types of an translation element, ie. "helloWord : String"
-}
typeDeclaration : Element -> SourceCode
typeDeclaration element =
    (elementMeta .key element)
        ++ " : "
        ++ placeholders element


placeholders : Element -> SourceCode
placeholders element =
    case element of
        ElementStatic _ ->
            "String"

        ElementFormat { placeholders } ->
            let
                num =
                    List.length placeholders
            in
                String.join " -> " (List.repeat (num + 1) "String")


body : Element -> SourceCode
body element =
    case element of
        ElementStatic static ->
            (tab ++ toString static.value)

        ElementFormat format ->
            (List.indexedMap formatComponentsImplementation format.components
                |> String.join "\n"
            )


head : Element -> SourceCode
head element =
    (elementMeta .key element)
        ++ (case element of
                ElementStatic static ->
                    ""

                ElementFormat format ->
                    " "
                        ++ String.join "" format.placeholders
           )
        ++ " ="


tab : SourceCode
tab =
    "    "


formatComponentsImplementation : Int -> FormatComponent -> SourceCode
formatComponentsImplementation index component =
    let
        prefix =
            if index == 0 then
                tab
            else
                tab ++ tab ++ "++ "
    in
        case component of
            FormatComponentStatic string ->
                prefix ++ toString string

            FormatComponentPlaceholder string ->
                prefix ++ String.trim string
