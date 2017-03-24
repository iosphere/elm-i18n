module Tests exposing (all)

import Test exposing (Test)
import Tests.LocalizedString


all : Test
all =
    Test.concat
        [ Tests.LocalizedString.all
        ]
