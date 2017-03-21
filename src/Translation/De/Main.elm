module Translation.Base.Main exposing (..)


greeting : String
greeting =
    "Hallo"


greetingWithName : String -> String
greetingWithName name =
    "Guten Tag, " ++ name
