module CSV.Template exposing (headers, placeholder)


headers : String
headers =
    "Module,Key,Comment,Supported Placeholders,Translation"


placeholder : String -> String
placeholder placeholder =
    "{{" ++ placeholder ++ "}}"
