module Tests exposing (all)

import Test exposing (Test)
import Tests.CSV.Export
import Tests.CSV.Import
import Tests.Localized


all : Test
all =
    Test.concat
        [ Tests.CSV.Export.all
        , Tests.CSV.Import.all
        , Tests.Localized.all
        ]
