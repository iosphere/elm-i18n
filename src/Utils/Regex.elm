module Utils.Regex exposing (submatchAt)

import List.Extra as List
import Regex


submatchAt : Int -> Maybe Regex.Match -> Maybe String
submatchAt index match =
    match
        |> Maybe.map (.submatches >> List.getAt index)
        |> Maybe.withDefault Nothing
        |> Maybe.withDefault Nothing
