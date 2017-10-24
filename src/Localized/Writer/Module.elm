module Localized.Writer.Module exposing (..)

{-| Provides code generation for Modules
-}

import Localized exposing (..)


{-| Return the complete implementation for the Module, needs a function to implement each Element.
-}
implementation : (Element -> SourceCode) -> Module -> SourceCode
implementation functionImplementation mod =
    head mod
        ++ elements functionImplementation mod


elements : (Element -> SourceCode) -> Module -> SourceCode
elements functionImplementation ( name, elements ) =
    (List.map functionImplementation elements
        |> String.join "\n\n\n"
        |> String.trim
        |> flip String.append "\n"
    )


head : Module -> SourceCode
head ( name, _ ) =
    "module "
        ++ name
        ++ " exposing (..)\n\n{-| -}\n\n"


importModule : Module -> SourceCode
importModule ( name, _ ) =
    "import " ++ name ++ "\n"


importModuleExposingAll : Module -> SourceCode
importModuleExposingAll ( name, _ ) =
    "import "
        ++ name
        ++ " exposing (..)\n"
