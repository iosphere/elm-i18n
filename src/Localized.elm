module Localized exposing (..)

{-| This module provides data structures describing localized string functions
and constants.
-}


type Element
    = ElementStatic Static
    | ElementFormat Format


type alias Static =
    { key : String
    , comment : String
    , value : String
    }


type alias Format =
    { key : String
    , comment : String
    , placeholders : List String
    , components : List FormatComponent
    }


type FormatComponent
    = FormatComponentStatic String
    | FormatComponentPlaceholder String
