module Tests.Localized exposing (..)

import Expect
import Localized
import Localized.Parser as Parser
import Localized.Parser.Internal as Parser
import Test exposing (..)


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
                    , ( "stringWithMultiLineComment", [] )
                    ]


expected : List Localized.Element
expected =
    [ Localized.ElementStatic
        { meta =
            { moduleName = mockModuleName
            , key = "myString"
            , comment = ""
            }
        , value = "Value"
        }
    , Localized.ElementStatic
        { meta =
            { moduleName = mockModuleName
            , key = "myString2"
            , comment = ""
            }
        , value = "Value2"
        }
    , Localized.ElementStatic
        { meta =
            { moduleName = mockModuleName
            , key = "myStringC"
            , comment = "My comment with a-hyphen"
            }
        , value = "ValueC"
        }
    , Localized.ElementFormat
        { meta =
            { moduleName = mockModuleName
            , key = "myFormat"
            , comment = ""
            }
        , placeholders = [ "label" ]
        , components =
            [ Localized.FormatComponentStatic "Prefix: "
            , Localized.FormatComponentPlaceholder "label"
            ]
        }
    , Localized.ElementFormat
        { meta =
            { moduleName = mockModuleName
            , key = "myFormat2"
            , comment = "My formatted comment"
            }
        , placeholders = [ "argument" ]
        , components =
            [ Localized.FormatComponentStatic "Newline after static: "
            , Localized.FormatComponentPlaceholder "argument"
            ]
        }
    , Localized.ElementStatic
        { meta =
            { moduleName = mockModuleName
            , key = "stringWithMultiLineComment"
            , comment = "My comment over two\nlines."
            }
        , value = ""
        }
    ]


mockModuleName : String
mockModuleName =
    "Translation.Test"


sourceString : String
sourceString =
    """module Translation.Test exposing (..)

{-| -}


myString : String
myString =
    "Value"


myString2 : String
myString2 = "Value2"


{-| My comment with a-hyphen
-}
myStringC : String
myStringC =
    "ValueC"


myFormat : String -> String
myFormat label =
    "Prefix: " ++ label


{-| My formatted comment
-}
myFormat2 : String -> String
myFormat2 argument =
    "Newline after static: "
        ++ argument


{-| My comment over two
lines.
-}
stringWithMultiLineComment : String
stringWithMultiLineComment =
    ""
"""
