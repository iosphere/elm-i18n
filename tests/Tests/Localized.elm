module Tests.Localized exposing (..)

import Expect
import Localized
import Localized.Parser as Parser
import Localized.Parser.Internal as Parser
import Test exposing (..)


all : Test
all =
    describe "Tests.LocalizedString"
        [ testParse, testStringDeclarations ]


testParse : Test
testParse =
    test "testParse" <|
        \() ->
            Parser.parse sourceString
                |> Expect.equal expected


testStringDeclarations : Test
testStringDeclarations =
    test "testStringDeclarations" <|
        \() ->
            Parser.stringDeclarations sourceString
                |> Expect.equal
                    [ ( "myString", [] )
                    , ( "myString2", [] )
                    , ( "myStringC", [] )
                    , ( "myFormat", [ "String" ] )
                    , ( "myFormat2", [ "String" ] )
                    ]


expected : List Localized.Element
expected =
    [ Localized.ElementStatic
        { moduleName = mockModuleName
        , key = "myString"
        , comment = ""
        , value = "Value"
        }
    , Localized.ElementStatic
        { moduleName = mockModuleName
        , key = "myString2"
        , comment = ""
        , value = "Value2"
        }
    , Localized.ElementStatic
        { moduleName = mockModuleName
        , key = "myStringC"
        , comment = "My comment"
        , value = "ValueC"
        }
    , Localized.ElementFormat
        { moduleName = mockModuleName
        , key = "myFormat"
        , comment = ""
        , placeholders = [ "label" ]
        , components =
            [ Localized.FormatComponentStatic "Prefix: "
            , Localized.FormatComponentPlaceholder "label"
            ]
        }
    , Localized.ElementFormat
        { moduleName = mockModuleName
        , key = "myFormat2"
        , comment = "My formatted comment"
        , placeholders = [ "argument" ]
        , components =
            [ Localized.FormatComponentStatic "Newline after static: "
            , Localized.FormatComponentPlaceholder "argument"
            ]
        }
    ]


mockModuleName : String
mockModuleName =
    "Translation.Test"


sourceString : String
sourceString =
    """module Translation.Test exposing (..)

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

{-| My formatted comment -}
myFormat2 : String -> String
myFormat2 argument =
    "Newline after static: "
        ++ argument
"""
