module Translation.Main exposing (..)

{-| -}


{-| A short greeting.
-}
greeting : String
greeting =
    "Hello"


{-| A personalized greeting. Note to transaltor: Use {{name}} as a placeholder
for the user's name.
-}
greetingWithName : String -> String
greetingWithName name =
    "Hello, "
        ++ name
