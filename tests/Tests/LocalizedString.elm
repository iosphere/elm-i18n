module Tests.LocalizedString exposing (..)

import Expect
import LocalizedString exposing (LocalizedString)
import Test exposing (..)


all : Test
all =
    describe "Tests.LocalizedString"
        [ testParse, testStringDeclarations ]


testParse : Test
testParse =
    test "testParse" <|
        \() ->
            LocalizedString.parse sourceString
                |> Expect.equal expected


testStringDeclarations : Test
testStringDeclarations =
    test "testStringDeclarations" <|
        \() ->
            LocalizedString.stringDeclarations sourceString
                |> Expect.equal
                    [ ( "myString", [] )
                    , ( "myString2", [] )
                    , ( "myStringC", [] )
                    , ( "myFormat", [ "String" ] )
                    ]


expected : List LocalizedString.LocalizedElement
expected =
    [ LocalizedString.Simple
        { key = "myString"
        , comment = ""
        , value = "Value"
        }
    , LocalizedString.Simple
        { key = "myString2"
        , comment = ""
        , value = "Value2"
        }
    , LocalizedString.Simple
        { key = "myStringC"
        , comment = "My comment"
        , value = "ValueC"
        }
    , LocalizedString.Format
        { key = "myFormat"
        , comment = ""
        , placeholders = [ "label" ]
        , components =
            [ LocalizedString.FormatComponentStatic "Prefix: "
            , LocalizedString.FormatComponentPlaceholder "label"
            ]
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

myFormat : String -> String
myFormat label =
    "Prefix: " ++ label
"""
