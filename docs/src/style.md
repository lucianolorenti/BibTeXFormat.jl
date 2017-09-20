
# Style
## BST
```
using BibTeX
using BibTeXFormat
bibliography = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"), "test/Clustering.bib")))
style        = BST.parse_file(joinpath(Pkg.dir("BibTeXFormat"),"test/format/apacite.bst"))
formatted_entries = format_entries(style, bibliography)
HTMLoutput        = write_to_string( HTMLBackend(),formatted_entries )
```

```@index
Pages    = ["style.jl"]
```

```@autodocs
Modules = [BibTeXFormat]
Pages    = ["style.jl"]
```
