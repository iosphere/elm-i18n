# i18n localization for Elm as a pre-build phase

![Travis](https://travis-ci.org/iosphere/elm-i18n.svg)

This is a proof of concept to illustrate how to localize an elm app.

The concept is to copy (or symlink) a root module for a language from the
language directory `./Translation/{Language}` to `./src/Translation`. Your code
imports modules under `./src/Translation` and does not know about languages.

The `index.js` script takes care of the copying/symlinking, clears the elm
artefacts cache, and provides an interface to build a localized version
of your app.

Installation:

`npm install elm-i18n -g`

Usage:

`cd example && elm-i18n-switch --output out -l En`

## Tools

This repository provides a few tools to extract string functions and constants
from modules containing translations (where one language can consist of multiple
modules, but each module only contains one language).

The tool is build using node.js with an Elm-Core.
To build the elm backend of the node.js part (if developing locally):
`make dist`.

### Export: Generate CSV from Elm source

```bash
elm-i18n-generator --root example/Translation --language De --export
```


Result:

```csv
Module,Key,Comment,Supported Placeholders,Translation
"Translation.Main","greeting","A short greeting.","","Hi"
"Translation.Main","greetingWithName","A personalized greeting. Use placeholder name for the user's name.","name","Guten Tag, {{name}}"
```

### Import: Generate Elm source code from CSV

```bash
elm-i18n-generator -l De --import export.csv
```

Result in import/DE/Translation/Main.elm:

```elm
module Translation.Main exposing (..)

{-| -}


{-| A short greeting.
-}
greeting : String
greeting =
    "Hi"


{-| A personalized greeting. Use placeholder name for the user's name.
-}
greetingWithName : String -> String
greetingWithName name =
    "Guten Tag, "
        ++ name
```

## Advantages

+ Each build of your app only contains one language.
+ No need to handle the current language in your elm app's model or view functions.
+ You can use any logic you like for the text snippets: constants, functions...
+ Allows you to create sub modules for parts of your app.
+ Full type safety
+ Auto completion (if you run the script at least once before starting the IDE).
+ For testing you can add a Translation `Test` and set your code base to use
  that before running tests. This way your tests do not change if you change the
  wording of your buttons, labels and fallbacks.
+ Compile-time errors for incomplete translations.
+ Compile-time errors are limited to the incomplete language, so you can
  continue shipping updates and fixes for the other languages.

## Disadvantages

- Language is no longer part of your view model and cannot be changed dynamically from within the app.
- Language selection has to be handled outside of the elm-app (by loading the appropriate js artefact).
