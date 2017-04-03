module Tests.PO.Export exposing (..)

import Expect
import Localized
import PO.Export as PO
import Test exposing (..)


all : Test
all =
    describe "Tests.PO.Export"
        [ testExport ]


testExport : Test
testExport =
    test "testExport" <|
        \() ->
            PO.generate elements
                |> Expect.equal expectedPO


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
    , Localized.ElementStatic
        { meta =
            { moduleName = "Translation.Second"
            , key = "myString"
            , comment = "Multiline\ncomment"
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


expectedPO : String
expectedPO =
    """#. MyComment
msgid "Translation.Test.myString"
msgstr "Value"

#. Multiline
#. comment
msgid "Translation.Second.myString"
msgstr "Value"

#.
#. i18n: placeholders: label
msgid "Translation.Test.myFormat"
msgstr "Prefix: %(label)s"
"""
