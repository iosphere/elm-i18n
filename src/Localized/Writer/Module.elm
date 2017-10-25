module Localized.Writer.Module
    exposing
        ( implementation
        , elements
        , head
        , importModule
        , importModuleExposingAll
        )

{-| Provides code generation for Localized.Modules
-}

import Localized


{-| Return the complete implementation for the Localized.Module, needs a function to implement each Localized.Element.
-}
implementation : (Localized.Element -> Localized.SourceCode) -> Localized.Module -> Localized.SourceCode
implementation functionImplementation mod =
    head mod
        ++ "\n"
        ++ elements functionImplementation mod


elements : (Localized.Element -> Localized.SourceCode) -> Localized.Module -> Localized.SourceCode
elements functionImplementation ( _, elements ) =
    List.map functionImplementation elements
        |> String.join "\n\n\n"
        |> String.trim
        |> flip String.append "\n"


head : Localized.Module -> Localized.SourceCode
head ( name, _ ) =
    "module "
        ++ name
        ++ " exposing (..)\n\n{-| -}\n\n"


importModule : Localized.Module -> Localized.SourceCode
importModule ( name, _ ) =
    "import " ++ name ++ "\n"


importModuleExposingAll : Localized.Module -> Localized.SourceCode
importModuleExposingAll ( name, _ ) =
    "import "
        ++ name
        ++ " exposing (..)\n"
