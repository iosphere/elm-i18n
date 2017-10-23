module Localized
    exposing
        ( Element(..)
        , Format
        , FormatComponent(..)
        , Meta
        , Static
        , ModuleName
        , Key
        , Comment
        , Value
        , SourceCode
        , Placeholder
        , Module
        , isEmptyFormatComponent
        )

{-| This module provides data structures describing localized string functions
and constants.

@docs Element, Meta, Static, Format, FormatComponent, ModuleName, Key, Comment, Value, Placeholder, Module, SourceCode, isEmptyFormatComponent
-}


{-| Describes a localized element consisting of either a static string or a
formatted string with placeholders.
-}
type Element
    = ElementStatic Static
    | ElementFormat Format


{-| The name of an Elm module.
-}
type alias ModuleName =
    String


{-| A Key.
-}
type alias Key =
    String


{-| Elm code (snipped) that will be written to an .elm file.
-}
type alias SourceCode =
    String


{-| String representation of a human readable comment.
-}
type alias Comment =
    String


{-| A String holding the final value of a static translation.
-}
type alias Value =
    String


{-| A Placeholder represents one argument given to the Translation functions
-}
type alias Placeholder =
    String


{-| Each localized element (static or format) has a key that is unique
within a module. The comment should help translators and others understand how
and where the localized element is used.
-}
type alias Meta =
    { moduleName : ModuleName
    , key : Key
    , comment : Comment
    }


{-| A static string can be localized but cannot contain placeholders.
It contains a single string value.
-}
type alias Static =
    { meta : Meta, value : Value }


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
    , placeholders : List Placeholder
    , components : List FormatComponent
    }


{-| The representation of an Elm module containing a list of Elements.
-}
type alias Module =
    ( ModuleName, List Element )


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
