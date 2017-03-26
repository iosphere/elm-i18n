module Tests.CSV.Import exposing (..)

import Expect
import CSV.Import as CSV
import Test exposing (..)
import CSV.Template


all : Test
all =
    describe "Tests.CSV.Import"
        [ testImport ]


testImport : Test
testImport =
    test "testImport" <|
        \() ->
            CSV.generate inputCSV
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
        ++ label"""
