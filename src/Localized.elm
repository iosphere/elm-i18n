module Localized
    exposing
        ( Element(..)
        , Format
        , FormatComponent(..)
        , Meta
        , Static
        , isEmptyFormatComponent
        )

{-| This module provides data structures describing localized string functions
and constants.

@docs Element, Meta, Static, Format, FormatComponent, isEmptyFormatComponent
-}


{-| Describes a localized element consisting of either a static string or a
formatted string with placeholders.
-}
type Element
    = ElementStatic Static
    | ElementFormat Format


{-| Each localized element (static or format) has a key that is unique
within a module. The comment should help translators and others understand how
and where the localized element is used.
-}
type alias Meta =
    { moduleName : String
    , key : String
    , comment : String
    }


{-| A static string can be localized but cannot contain placeholders.
It contains a single string value.
-}
type alias Static =
    { meta : Meta, value : String }


{-| A formatted string can contain placeholders and static components. This
allows us to describe strings that contain dynamic values.

"Hello, {{name}}" would be represented as:

    { placeholders : ["name"]
    , components :
        [ FormatComponentStatic "Hello, "
        , FormatComponentPlaceholder "name"
        ]
    }
-}
type alias Format =
    { meta : Meta
    , placeholders : List String
    , components : List FormatComponent
    }


{-| A list of components make up a formatted element. See Format.
-}
type FormatComponent
    = FormatComponentStatic String
    | FormatComponentPlaceholder String


{-| Returns true if the component is empty.
-}
isEmptyFormatComponent : FormatComponent -> Bool
isEmptyFormatComponent comp =
    case comp of
        FormatComponentStatic string ->
            String.isEmpty string

        FormatComponentPlaceholder string ->
            String.isEmpty string
