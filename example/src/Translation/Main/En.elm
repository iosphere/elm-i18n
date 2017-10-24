module Translation.Main.En exposing (..)

{-| -}

{-| A short greeting.
-}
greeting : String
greeting =
    "Hello"


greetingWithName : String -> String
greetingWithName name =
    "Hello, "
        ++ name
