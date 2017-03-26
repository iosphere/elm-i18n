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
                |> Debug.log "declarations"
    in
        List.filterMap
            (\( key, params ) ->
                case findStaticElementForKey source key of
                    Just simple ->
                        Just simple

                    Nothing ->
                        -- try format
                        findFormatElementForKey source key
            )
            stringKeysAndParameters
