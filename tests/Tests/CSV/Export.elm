module Tests.CSV.Export exposing (..)

import CSV.Export as CSV
import CSV.Template
import Expect
import Localized
import Test exposing (..)


testExport : Test
testExport =
    test "testExport" <|
        \() ->
            CSV.generate elements
                |> Expect.equal expectedCSV


elements : List Localized.Element
elements =
    [ Localized.ElementStatic
        { meta =
            { moduleName = "Translation.Second"
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


expectedCSV : String
expectedCSV =
    CSV.Template.headers ++ """
"Translation.Second","myString","MyComment","","Value"
"Translation.Test","myFormat","","label","Prefix: {{label}}"
"""
