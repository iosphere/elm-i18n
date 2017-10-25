module Localized.Parser exposing (parse)

{-| The parser parses elm code (one module) into a list of localized elements.

@docs parse

-}

import Localized
import Localized.Parser.Internal exposing (..)


{-| Parses the source code of an elm module and
returns a list of localized elements.
-}
parse : Localized.SourceCode -> List Localized.Element
parse source =
    let
        stringKeysAndParameters =
            stringDeclarations source

        moduleName =
            findModuleName source
    in
        List.filterMap
            (\( key, _ ) ->
                case findStaticElementForKey moduleName source key of
                    Just simple ->
                        Just simple

                    Nothing ->
                        -- try format
                        findFormatElementForKey moduleName source key
            )
            stringKeysAndParameters
