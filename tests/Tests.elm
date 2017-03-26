module Tests exposing (all)

import Test exposing (Test)
import Tests.Localized


all : Test
all =
    Test.concat
        [ Tests.Localized.all
        ]
