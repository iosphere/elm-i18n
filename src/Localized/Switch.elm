module Localized.Switch exposing (generate)

{-|

    Reads in all the Translation.elm files and generates a master switch for
    them. Elements only present in one of them will still be added.
-}

import Dict exposing (Dict)
import Localized
import Localized.Parser as Parser
import Localized.Writer.Module
import Localized.Writer.Element exposing (tab)


generate : List Localized.LangCode -> List Localized.SourceCode -> List ( Localized.ModuleName, Localized.SourceCode )
generate languages sources =
    mainModule languages
        :: (sources
                |> List.map Parser.parse
                |> flatten2D
                |> List.map (removeLocale languages)
                |> unique
                |> indexBy (Localized.elementMeta .moduleName)
                |> Dict.toList
                |> List.map (switchSource languages)
           )


unique : List Localized.Element -> List Localized.Element
unique elements =
    u elements []


u : List Localized.Element -> List Localized.Element -> List Localized.Element
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


member : Localized.Element -> List Localized.Element -> Bool
member e list =
    let
        sameElement e1 e2 =
            case ( e1, e2 ) of
                ( Localized.ElementFormat _, Localized.ElementStatic _ ) ->
                    False

                ( Localized.ElementStatic _, Localized.ElementFormat _ ) ->
                    False

                ( Localized.ElementStatic m1, Localized.ElementStatic m2 ) ->
                    m1.meta.moduleName == m2.meta.moduleName && m1.meta.key == m2.meta.key

                ( Localized.ElementFormat m1, Localized.ElementFormat m2 ) ->
                    m1.meta.moduleName == m2.meta.moduleName && m1.meta.key == m2.meta.key
    in
        List.any (sameElement e) list


indexBy : (Localized.Element -> comparable) -> List Localized.Element -> Dict comparable (List Localized.Element)
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


switchSource : List Localized.LangCode -> Localized.Module -> ( Localized.ModuleName, Localized.SourceCode )
switchSource languages mod =
    let
        ( moduleName, _ ) =
            mod
    in
        ( moduleName
        , Localized.Writer.Module.head mod
            ++ Localized.Writer.Module.importModuleExposingAll ( "Translation", [] )
            ++ (String.join "" <|
                    List.map
                        (Localized.Writer.Module.importModule << Localized.namedModule << Localized.languageModuleName moduleName)
                        languages
               )
            ++ "\n\n"
            ++ Localized.Writer.Module.elements (elementSource languages) mod
        )


elementSource : List Localized.LangCode -> Localized.Element -> Localized.SourceCode
elementSource languages element =
    let
        name =
            Localized.elementMeta .key element

        moduleName =
            Localized.elementMeta .moduleName element

        placeholders =
            Localized.Writer.Element.placeholders element
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


mainModule : List Localized.LangCode -> ( Localized.ModuleName, Localized.SourceCode )
mainModule languages =
    let
        name =
            "Translation"

        mod =
            ( name, [] )
    in
        ( name
        , Localized.Writer.Module.head mod
            ++ "type Language = "
            ++ String.join " | " languages
            ++ "\n"
        )


removeLocale : List Localized.LangCode -> Localized.Element -> Localized.Element
removeLocale langs element =
    langs |> List.foldr Localized.elementRemoveLang element
