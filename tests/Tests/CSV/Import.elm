module Tests.CSV.Import exposing (..)

import CSV.Export as Export
import CSV.Import as CSV
import CSV.Template
import Expect
import Localized
import Localized.Parser as Localized
import Localized.Writer as Writer
import Test exposing (..)


all : Test
all =
    describe "Tests.CSV.Import"
        [ testGenerate
        , testImport
        , testFullCircle
        ]


testGenerate : Test
testGenerate =
    test "testGenerate" <|
        \() ->
            CSV.generate inputCSV
                |> Expect.equal [ ( "Translation.Test", elements ) ]


testImport : Test
testImport =
    test "testImport" <|
        \() ->
            CSV.generate inputCSV
                |> Writer.generate
                |> Expect.equal [ ( "Translation.Test", expectedSource ) ]


testFullCircle : Test
testFullCircle =
    test "testFullCircle" <|
        \() ->
            Localized.parse expectedSource
                |> Export.generate
                |> CSV.generate
                |> Writer.generate
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

{-| -}


{-| My comment
-}
myString : String
myString =
    "Value"


myFormat : String -> String
myFormat label =
    "Prefix: "
        ++ label
"""


elements : List Localized.Element
elements =
    [ Localized.ElementStatic
        { meta =
            { moduleName = "Translation.Test"
            , key = "myString"
            , comment = "My comment"
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
