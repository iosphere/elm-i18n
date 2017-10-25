module Localized.Switch exposing (generate)

{-|

    Reads in all the Translation.elm files and generates a master switch for
    them. Elements only present in one of them will still be added.
-}

import Dict exposing (Dict)
import Localized exposing (..)
import Localized.Parser as Parser
import Localized.Writer.Module as Module
import Localized.Writer.Element as Element exposing (tab)


generate : List LangCode -> List SourceCode -> List ( ModuleName, SourceCode )
generate languages sources =
    mainModule languages
        :: (sources
                |> List.map Parser.parse
                |> flatten2D
                |> List.map (removeLocale languages)
                |> unique
                |> indexBy (elementMeta .moduleName)
                |> Dict.toList
                |> List.map (switchSource languages)
           )


unique : List Element -> List Element
unique elements =
    u elements []


u : List Element -> List Element -> List Element
u list have =
    case list of
        e :: rest ->
            if member e have then
                u rest have
            else
                u rest (e :: have)

        [] ->
            have


flatten2D : List (List a) -> List a
flatten2D list =
    List.foldr (++) [] list


member : Element -> List Element -> Bool
member e list =
    let
        sameElement e1 e2 =
            case ( e1, e2 ) of
                ( ElementFormat _, ElementStatic _ ) ->
                    False

                ( ElementStatic _, ElementFormat _ ) ->
                    False

                ( ElementStatic m1, ElementStatic m2 ) ->
                    m1.meta.moduleName == m2.meta.moduleName && m1.meta.key == m2.meta.key

                ( ElementFormat m1, ElementFormat m2 ) ->
                    m1.meta.moduleName == m2.meta.moduleName && m1.meta.key == m2.meta.key
    in
        List.any (sameElement e) list


indexBy : (Element -> comparable) -> List Element -> Dict comparable (List Element)
indexBy keymaker elements =
    elements
        |> List.foldr
            (\e d ->
                Dict.update (keymaker e)
                    (\v ->
                        case v of
                            Nothing ->
                                Just [ e ]

                            Just l ->
                                Just (e :: l)
                    )
                    d
            )
            Dict.empty


switchSource : List LangCode -> Module -> ( ModuleName, SourceCode )
switchSource languages mod =
    let
        ( moduleName, _ ) =
            mod
    in
        ( moduleName
        , Module.head mod
            ++ Module.importModuleExposingAll ( "Translation", [] )
            ++ (String.join "" <| List.map (Module.importModule << namedModule << (languageModuleName moduleName)) languages)
            ++ "\n\n"
            ++ Module.elements (elementSource languages) mod
        )


elementSource : List LangCode -> Element -> SourceCode
elementSource languages element =
    let
        name =
            elementMeta .key element

        moduleName =
            elementMeta .moduleName element

        placeholders =
            Element.placeholders element
    in
        name
            ++ " : Language -> "
            ++ placeholders
            ++ "\n"
            ++ name
            ++ " language =\n"
            ++ (tab ++ "case language of\n")
            ++ (String.join "\n" <|
                    List.map
                        (\l ->
                            (tab ++ tab)
                                ++ l
                                ++ " -> "
                                ++ moduleName
                                ++ "."
                                ++ l
                                ++ "."
                                ++ name
                        )
                        languages
               )


mainModule : List LangCode -> ( ModuleName, SourceCode )
mainModule languages =
    let
        name =
            "Translation"

        mod =
            ( name, [] )
    in
        ( name
        , Module.head mod
            ++ "type Language = "
            ++ (String.join " | " languages)
            ++ "\n"
        )


removeLocale : List LangCode -> Element -> Element
removeLocale langs element =
    langs |> List.foldr elementRemoveLang element
