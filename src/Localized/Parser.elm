module Localized.Parser exposing (parse)

import Localized
import Localized.Parser.Internal exposing (..)


{-| Parses an elm source code string and returns a list of localized elements.
-}
parse : String -> List Localized.Element
parse source =
    let
        stringKeysAndParameters =
            stringDeclarations source

        moduleName =
            findModuleName source
    in
        List.filterMap
            (\( key, params ) ->
                case findStaticElementForKey moduleName source key of
                    Just simple ->
                        Just simple

                    Nothing ->
                        -- try format
                        findFormatElementForKey moduleName source key
            )
            stringKeysAndParameters
