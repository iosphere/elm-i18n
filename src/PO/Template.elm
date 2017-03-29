module PO.Template exposing (placeholder)


placeholder : String -> String
placeholder placeholder =
    "%(" ++ placeholder ++ ")s"


placeholderCommentPrefix : String
placeholderCommentPrefix =
    " i18n: placeholders: "
