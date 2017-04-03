module PO.Template exposing (placeholder, placeholderCommentPrefix)


placeholder : String -> String
placeholder placeholder =
    "%(" ++ placeholder ++ ")s"


placeholderCommentPrefix : String
placeholderCommentPrefix =
    "i18n: placeholders: "
