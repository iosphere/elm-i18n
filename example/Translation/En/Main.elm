module Translation.Main exposing (..)


greeting : String
greeting =
    "Hello"


greetingWithName : String -> String
greetingWithName name =
    "Hello, "
        ++ name
        ++ "test"


salute : String
salute =
    "General"
