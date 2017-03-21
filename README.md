# i18n localization for Elm as a pre-build phase

This is a proof of concept to illustrate how to localize an elm app.

The concept is to copy (or symlink) a root module for a language from the
language directory to `Translation.Base`. The `index.js` script then clears the
elm artefacts cache and provides an interface to build a localized version of
the script.

Usage:

`./index.js --output out -l En`

## Advantages

+ Each script only contains one language.
+ No need to handle the current language in your elm app's model or view functions.
+ You can use any logic you like for the text snippets: constants, functions...
+ Allows you to create sub modules for parts of your app.
+ Full type safety
+ Auto completion (if you run the script at least once before starting the IDE).


## Disadvantages

- Language is no longer part of your view model and cannot be changed dynamically from within the app.
- Language selection has to be handled outside of the elm-app (by loading the appropriate js artefact).
