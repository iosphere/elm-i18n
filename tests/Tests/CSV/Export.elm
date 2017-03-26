module Tests.CSV.Export exposing (..)

import Expect
import Localized
import CSV.Export as CSV
import Test exposing (..)


all : Test
all =
    describe "Tests.CSV.Export"
        [ testExport ]


testExport : Test
testExport =
    test "testParse" <|
        \() ->
            CSV.generate elements
                |> Expect.equal expectedCSV


elements : List Localized.Element
elements =
    [ Localized.ElementStatic
        { key = "myString"
        , comment = "MyComment"
        , value = "Value"
        }
    , Localized.ElementFormat
        { key = "myFormat"
        , comment = ""
        , placeholders = [ "label" ]
        , components =
            [ Localized.FormatComponentStatic "Prefix: "
            , Localized.FormatComponentPlaceholder "label"
            ]
        }
    ]


expectedCSV : String
expectedCSV =
    """myString,MyComment,Value
myFormat,,Prefix: {{label}}"""
