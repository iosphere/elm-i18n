module Localized.Writer exposing (generate)

{-| This is the inverse of the Localized.Parser. The Writer takes a list of
module names and associated localized elements and returns the source code for
elm modules implementing the localized elements.

@docs generate
-}

import Localized exposing (..)


{-| Generate elm-source code for a list of modules and their associated
localized elements.
-}
generate : List Module -> List ( ModuleName, SourceCode )
generate =
    List.map
        (\( modulename, elements ) ->
            ( modulename, moduleImplementation modulename elements )
        )


moduleImplementation : ModuleName -> List Element -> SourceCode
moduleImplementation name elements =
    "module "
        ++ name
        ++ " exposing (..)\n\n{-| -}\n\n\n"
        ++ (List.map functionFromElement elements
                |> String.join "\n\n\n"
                |> String.trim
                |> flip String.append "\n"
           )


functionFromElement : Element -> SourceCode
functionFromElement element =
    case element of
        ElementStatic static ->
            functionStatic static

        ElementFormat format ->
            functionFormat format


tab : SourceCode
tab =
    "    "


functionStatic : Static -> SourceCode
functionStatic staticLocalized =
    comment staticLocalized.meta.comment
        ++ signature staticLocalized.meta.key []
        ++ ("\n" ++ tab ++ toString staticLocalized.value)


functionFormat : Format -> SourceCode
functionFormat format =
    comment format.meta.comment
        ++ signature format.meta.key format.placeholders
        ++ "\n"
        ++ (List.indexedMap formatComponentsImplementation format.components
                |> String.join "\n"
           )


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


signature : Key -> List Placeholder -> SourceCode
signature key placeholders =
    let
        num =
            List.length placeholders

        types =
            if num == 0 then
                "String"
            else
                String.join " -> " (List.repeat (num + 1) "String")

        parameters =
            if num == 0 then
                ""
            else
                " " ++ String.join " " placeholders
    in
        (key ++ " : " ++ types ++ "\n")
            ++ (key ++ parameters ++ " =")


comment : Comment -> SourceCode
comment string =
    if String.isEmpty string then
        ""
    else
        "{-| " ++ string ++ "\n-}\n"
