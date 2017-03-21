module Translation.Base.Main exposing (..)


greeting : String
greeting =
    "Hello"


greetingWithName : String -> String
greetingWithName name =
    "Hello, " ++ name
