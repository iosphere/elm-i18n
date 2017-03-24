module Tests.LocalizedString exposing (..)

import Expect
import LocalizedString exposing (LocalizedString)
import Test exposing (..)


all : Test
all =
    describe "Tests.LocalizedString"
        [ testString ]


testString : Test
testString =
    test "Test view" <|
        \() ->
            LocalizedString.parse sourceString
                |> Expect.equal expected


expected : List LocalizedString
expected =
    [ { key = "myString"
      , comment = ""
      , value = "Value"
      }
    , { key = "myString2"
      , comment = ""
      , value = "Value2"
      }
    , { key = "myStringC"
      , comment = "My comment"
      , value = "ValueC"
      }
    ]


sourceString : String
sourceString =
    """
myString : String
myString =
    "Value"

myString2 : String
myString2 = "Value2"

{-| My comment -}
myStringC : String
myStringC =
    "ValueC"

"""
