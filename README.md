# i18n localization for Elm as a pre-build phase

[![Travis](https://travis-ci.org/iosphere/elm-i18n.svg?branch=master)](https://travis-ci.org/iosphere/elm-i18n)
[![npm version](https://badge.fury.io/js/elm-i18n.svg)](https://badge.fury.io/js/elm-i18n)

elm-i18n provides tools and a concept for localizing elm apps. The idea is to
treat localized text as constants (or functions). To achieve this, localized
content is placed in separate modules. Each language can consist of
multiple modules, but each module contains only one language.

**The correct set of language modules is symlinked or copied into place before
compiling the elm app. The result is a localized compiled version of your app.**
When repeating this process for multiple languages the compuler re-uses the
cache and only the translation specific modules are cleared from the cache.

The elm-package is aimed at tool developers who want to parse elm-code into
localized elements, read or write CSV or PO files. **If you want to use this
tool for your elm-project you only need the information in this README.**

## Features:

* Switch languages:
    * Switch the language of your elm app before building
    * Easily build multiple localized version of your app
*   `CSV <-> ELM <-> PO`
    * Generate **CSV** and **PO** files from your localization module's elm code
    * Generate your localization module's elm code from CSV and PO files



## Suggested project file structure

Note that the language identifier is only included in the directory name and
excluded from the Translation module names:

```
project
├── src/
│   ├── Main.elm (e.g. imports Translation.Main)
│   ├── View.elm (e.g. imports Translation.View)
│   └──>Translation (sym-linked to current directory, e.g. project/Translation/De/)
└── Translation/
    ├── De/
    │   ├── Main.elm (module Translation.Main)
    │   └── View.elm (module Translation.View)
    └── En/
        ├── Main.elm (module Translation.Main)
        └── View.elm (module Translation.View)
```

## Installation:

The tool-set is available as a node package and is backed by elm code:

`npm install elm-i18n -g`

## Switch language as a prebuild phase

In order to switch the language for compilation to `En`, simply execute the
following command at the root of your elm app:

`elm-i18n-switch -l En`

To switch the language and compile a localized version of your app (to `dist/en.js`):

`elm-i18n-switch -l En --output dist`

If your code is not stored in `src` or your main app module is not `Main.elm`:

`elm-i18n-switch -l En --output dist --src myDir --elmFile MyMain.elm`

If your root `Translation` module is called `MyTranslation`:

`elm-i18n-switch -l En --rootModule MyTranslation`


## Codegen tools

This repository provides a few tools to extract string functions and constants
from modules containing translations (where one language can consist of multiple
modules, but each module only contains one language).

### CSV

#### Export: Generate CSV from Elm source

```bash
elm-i18n-generator --format CSV --root example/Translation --language De --export
```

Result:

```csv
Module,Key,Comment,Supported Placeholders,Translation
"Translation.Main","greeting","A short greeting.","","Hi"
"Translation.Main","greetingWithName","A personalized greeting. Use placeholder name for the user's name.","name","Guten Tag, {{name}}"
```

#### Import: Generate Elm source code from CSV

```bash
elm-i18n-generator --format CSV -l De --import export.csv
```

Result in `import/De/Translation/Main.elm`:

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

### PO

For more information about the PO file format visit:
https://www.gnu.org/savannah-checkouts/gnu/gettext/manual/html_node/PO-Files.html

#### Export: Generate PO from Elm source:

```bash
elm-i18n-generator --format PO --root example/Translation --language De --export
```

Result:

```po
#. A short greeting.
msgid "Translation.Main.greeting"
msgstr "Hi"

#. A personalized greeting. Use placeholder name for the user's name.
#. i18n: placeholders: name
msgid "Translation.Main.greetingWithName"
msgstr "Guten Tag, %(name)s"
```

#### Import: Generate Elm source code from PO

```bash
elm-i18n-generator --format PO --language De --import export.po
```

Results in the same `import/De/Translation/Main.elm`
as in the [CSV example](#import-generate-elm-source-code-from-csv).

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
+ Get started with a new language quickly by exporting all strings for
  an existing language, replacing all value in the CSV with "TODO" and then
  import the CSV for the new language, which will create all `Translation`
  modules.

## Disadvantages

- Language is no longer part of your view model and cannot be changed dynamically from within the app.
  *However, you can add a constant with the current language code and have different code paths if that
  is required.*
- Language selection has to be handled outside of the elm-app (by loading the appropriate js artefact).

## Building elm-i18n

The tool is built using node.js with an Elm-Core.
To build the elm backend of the node.js part (if developing locally):
`make dist`.
