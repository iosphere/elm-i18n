module Localized.Writer exposing (generate)

{-| This is the inverse of the Localized.Parser. The Writer takes a list of
module names and associated localized elements and returns the source code for
elm modules implementing the localized elements.

@docs generate
-}

import Localized


{-| Generate elm-source code for a list of modules and their associated
localized elements.
-}
generate : List ( String, List Localized.Element ) -> List ( String, String )
generate =
    List.map
        (\( modulename, elements ) ->
            ( modulename, moduleImplementation modulename elements )
        )


moduleImplementation : String -> List Localized.Element -> String
moduleImplementation name elements =
    "module "
        ++ name
        ++ " exposing (..)\n\n{-| -}\n\n\n"
        ++ (List.map functionFromElement elements
                |> String.join "\n\n\n"
                |> String.trim
                |> flip String.append "\n"
           )


functionFromElement : Localized.Element -> String
functionFromElement element =
    case element of
        Localized.ElementStatic static ->
            functionStatic static

        Localized.ElementFormat format ->
            functionFormat format


tab : String
tab =
    "    "


functionStatic : Localized.Static -> String
functionStatic staticLocalized =
    comment staticLocalized.meta.comment
        ++ signature staticLocalized.meta.key []
        ++ ("\n" ++ tab ++ toString staticLocalized.value)


functionFormat : Localized.Format -> String
functionFormat format =
    comment format.meta.comment
        ++ signature format.meta.key format.placeholders
        ++ "\n"
        ++ (List.indexedMap formatComponentsImplementation format.components
                |> String.join "\n"
           )


formatComponentsImplementation : Int -> Localized.FormatComponent -> String
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


signature : String -> List String -> String
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


comment : String -> String
comment string =
    if String.isEmpty string then
        ""
    else
        "{-| " ++ string ++ "\n-}\n"
