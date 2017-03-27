module Translation.Main exposing (..)

{-| -}


{-| A short greeting.
-}
greeting : String
greeting =
    "Hi"


{-| A personalized greeting. Use placeholder name for the user's name.
-}
greetingWithName : String -> String
greetingWithName name =
    "Guten Tag, "
        ++ name
