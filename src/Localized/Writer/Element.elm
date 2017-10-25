module Localized.Writer.Element exposing (..)

import Localized


{-| Returns types of an translation element, ie. "helloWord : String"
-}
typeDeclaration : Localized.Element -> Localized.SourceCode
typeDeclaration element =
    (Localized.elementMeta .key element)
        ++ " : "
        ++ placeholders element


placeholders : Localized.Element -> Localized.SourceCode
placeholders element =
    case element of
        Localized.ElementStatic _ ->
            "String"

        Localized.ElementFormat { placeholders } ->
            let
                num =
                    List.length placeholders
            in
                String.join " -> " (List.repeat (num + 1) "String")


body : Localized.Element -> Localized.SourceCode
body element =
    case element of
        Localized.ElementStatic static ->
            (tab ++ toString static.value)

        Localized.ElementFormat format ->
            (List.indexedMap formatComponentsImplementation format.components
                |> String.join "\n"
            )


head : Localized.Element -> Localized.SourceCode
head element =
    (Localized.elementMeta .key element)
        ++ (case element of
                Localized.ElementStatic static ->
                    ""

                Localized.ElementFormat format ->
                    " "
                        ++ String.join "" format.placeholders
           )
        ++ " ="


tab : Localized.SourceCode
tab =
    "    "


formatComponentsImplementation : Int -> Localized.FormatComponent -> Localized.SourceCode
formatComponentsImplementation index component =
    let
        prefix =
            if index == 0 then
                tab
            else
                tab ++ tab ++ "++ "
    in
        case component of
            Localized.FormatComponentStatic string ->
                prefix ++ toString string

            Localized.FormatComponentPlaceholder string ->
                prefix ++ String.trim string
