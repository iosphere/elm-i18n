module Localized.Writer exposing (generate)

{-| This is the inverse of the Localized.Parser. The Writer takes a list of
module names and associated localized elements and returns the source code for
elm modules implementing the localized elements.

@docs generate

-}

import Localized exposing (..)
import Localized.Writer.Module as Module
import Localized.Writer.Element as Element exposing (tab)


{-| Generate elm-source code for a list of modules and their associated
localized elements.
-}
generate : List Module -> List ( ModuleName, SourceCode )
generate =
    List.map moduleImplementation


moduleImplementation : Module -> ( ModuleName, SourceCode )
moduleImplementation mod =
    let
        ( moduleName, _ ) =
            mod
    in
        ( moduleName
        , Module.implementation element mod
        )


element : Element -> SourceCode
element element =
    let
        c =
            elementMeta .comment element
    in
        comment c
            ++ Element.typeDeclaration element
            ++ "\n"
            ++ Element.head element
            ++ "\n"
            ++ Element.body element


comment : Comment -> SourceCode
comment string =
    if String.isEmpty string then
        ""
    else
        "{-| " ++ string ++ "\n-}\n"
