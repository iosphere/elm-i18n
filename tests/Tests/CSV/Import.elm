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
                |> Expect.equal [ ( "Translation.Test", expectedSource ) ]


testFullCircle : Test
testFullCircle =
    test "testFullCircle" <|
        \() ->
            Localized.parse expectedSource
                |> Export.generate
                |> CSV.generate
                |> Expect.equal [ ( "Translation.Test", expectedSource ) ]


inputCSV : String
inputCSV =
    CSV.Template.headers
        ++ """
"Translation.Test","myString","My comment","","Value"
"Translation.Test","myFormat","","label","Prefix: {{label}}"
"""


expectedSource : String
expectedSource =
    """module Translation.Test exposing (..)

{-| My comment -}
myString : String
myString =
    "Value"

myFormat : String -> String
myFormat label =
    "Prefix: "
        ++ label
"""
