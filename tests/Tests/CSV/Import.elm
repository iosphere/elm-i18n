module Tests.CSV.Import exposing (..)

import Localized.Parser as Localized
import CSV.Export as Export
import CSV.Import as CSV
import CSV.Template
import Expect
import Test exposing (..)


all : Test
all =
    describe "Tests.CSV.Import"
        [ testImport, testFullCircle ]


testImport : Test
testImport =
    test "testImport" <|
        \() ->
            CSV.generate inputCSV
                |> Expect.equal expectedSource


testFullCircle : Test
testFullCircle =
    test "testFullCircle" <|
        \() ->
            Localized.parse expectedSource
                |> Export.generate
                |> CSV.generate
                |> Expect.equal expectedSource


inputCSV : String
inputCSV =
    CSV.Template.headers
        ++ """
"myString","My comment","","Value"
"myFormat","","label","Prefix: {{label}}"
"""


expectedSource : String
expectedSource =
    """{-| My comment -}
myString : String
myString =
    "Value"

myFormat : String -> String
myFormat label =
    "Prefix: "
        ++ label
"""
