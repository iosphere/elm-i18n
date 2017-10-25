module Localized
    exposing
        ( Element(ElementStatic, ElementFormat)
        , Format
        , FormatComponent
            ( FormatComponentStatic
            , FormatComponentPlaceholder
            )
        , Meta
        , Static
        , ModuleName
        , Key
        , Comment
        , Value
        , SourceCode
        , Placeholder
        , LangCode
        , Module
        , ModuleImplementation
        , elementMeta
        , languageModuleName
        , isEmptyFormatComponent
        , elementRemoveLang
        , namedModule
        )

{-| This module provides data structures describing localized string functions
and constants.

@docs Element, Meta, Static, Format, FormatComponent, ModuleName, Key, Comment, Value, Placeholder, Module, ModuleImplementation, SourceCode, LangCode, isEmptyFormatComponent, elementMeta, languageModuleName, elementRemoveLang, namedModule

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
    { meta : Meta
    , value : Value
    }


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


{-| The representation of an Elm module with its complete source
-}
type alias ModuleImplementation =
    ( ModuleName, SourceCode )


{-| A list of components make up a formatted element. See Format.
-}
type FormatComponent
    = FormatComponentStatic String
    | FormatComponentPlaceholder String


{-| A language code as a String used for module names, ie. "En" or "De"
-}
type alias LangCode =
    String


{-| Returns true if the component is empty.
-}
isEmptyFormatComponent : FormatComponent -> Bool
isEmptyFormatComponent comp =
    case comp of
        FormatComponentStatic string ->
            String.isEmpty string

        FormatComponentPlaceholder string ->
            String.isEmpty string


{-| Returns an attribute of any Element
-}
elementMeta : (Meta -> val) -> Element -> val
elementMeta accessor element =
    case element of
        ElementStatic e ->
            accessor e.meta

        ElementFormat e ->
            accessor e.meta


{-| Returns an empty Module with a name indicating the locale.
-}
languageModuleName : ModuleName -> LangCode -> ModuleName
languageModuleName name lang =
    name ++ "." ++ lang


{-| Constructs a new Module with the given name
-}
namedModule : ModuleName -> Module
namedModule name =
    ( name, [] )


{-| Removes a locale "En" from a module name like "Translation.Main.En"
-}
elementRemoveLang : LangCode -> Element -> Element
elementRemoveLang lang element =
    let
        moduleName =
            elementMeta .moduleName element

        cleanedName =
            String.split "." moduleName
                |> List.filter (\p -> p /= lang)
                |> String.join "."

        changeName meta name =
            { meta | moduleName = name }
    in
        case element of
            ElementStatic e ->
                ElementStatic { e | meta = changeName e.meta cleanedName }

            ElementFormat e ->
                ElementFormat { e | meta = changeName e.meta cleanedName }
