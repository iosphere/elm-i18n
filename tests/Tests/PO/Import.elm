module Tests.PO.Import exposing (..)

import Expect
import Localized
import PO.Import as PO
import PO.Import.Internal as PO
import Test exposing (..)


all : Test
all =
    describe "Tests.PO.Import"
        [ testImport, testKeys, testPlaceholders, testPlaceholdersFromComment ]


testImport : Test
testImport =
    test "testImport" <|
        \() ->
            PO.generate inputPO
                |> Expect.equal [ ( "Translation.Test", elements ) ]


testKeys : Test
testKeys =
    test "testKeys" <|
        \() ->
            PO.keys inputPO
                |> Expect.equal
                    [ ( "Translation.Test", [ "myString", "myFormat" ] ) ]


testPlaceholders : Test
testPlaceholders =
    test "testPlaceholders" <|
        \() ->
            [ PO.placeholdersInValue (toString "Prefix %(placeholder)s")
            , PO.placeholdersInValue (toString "Prefix %(placeholder)")
            , PO.placeholdersInValue (toString "%(some)s")
            ]
                |> Expect.equal
                    [ [ "placeholder" ]
                    , []
                    , [ "some" ]
                    ]


testPlaceholdersFromComment : Test
testPlaceholdersFromComment =
    test "testPlaceholdersFromComment" <|
        \() ->
            [ PO.placeholdersFromPoComment ("#.\n#. i18n: placeholders: label")
            , PO.placeholdersFromPoComment ("#. My Comment")
            ]
                |> Expect.equal
                    [ [ "label" ]
                    , []
                    ]


elements : List Localized.Element
elements =
    [ Localized.ElementStatic
        { meta =
            { moduleName = "Translation.Test"
            , key = "myString"
            , comment = "MyComment"
            }
        , value = "Value"
        }
    , Localized.ElementFormat
        { meta =
            { moduleName = "Translation.Test"
            , key = "myFormat"
            , comment = ""
            }
        , placeholders = [ "label" ]
        , components =
            [ Localized.FormatComponentStatic "Prefix: "
            , Localized.FormatComponentPlaceholder "label"
            ]
        }
    ]


inputPO : String
inputPO =
    """#. MyComment
msgid "Translation.Test.myString"
msgstr "Value"

#.
#. i18n: placeholders: label
msgid "Translation.Test.myFormat"
msgstr "Prefix: %(label)s"
"""
