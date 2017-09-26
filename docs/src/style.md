
# Style

## Julia Format

### Example

```julia
using BibTeX
using BibTeXFormat

bibliography = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"),
                             "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
HTMLoutput        = write_to_string( HTMLBackend(),formatted_entries )
```

```@index
Pages    = ["style.jl"]
```

```@autodocs
Modules = [BibTeXFormat]
Pages    = ["style.jl"]
```

## BST

```
using BibTeX
using BibTeXFormat
bibliography = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"), "test/Clustering.bib")))
style        = BST.parse_file(joinpath(Pkg.dir("BibTeXFormat"),"test/format/apacite.bst"))
latexOutput = format_entries(style, bibliography)
```

### References

```@index
Modules=[BibTeXFormat.BST]
Pages = ["style/bst/bst.jl", "style/bst/interpreter.jl", "style/bst/names.jl"]
```

```@autodocs
Modules=[BibTeXFormat.BST]
Pages = ["style/bst/bst.jl", "style/bst/interpreter.jl", "style/bst/names.jl"]
```
## Name formatting

BibTeX-like name formatting.

```jldoctest
julia> import BibTeXFormat.BST: format_name

julia> name = "Charles Louis Xavier Joseph de la Vallee Poussin";

julia> print(format_name(name, "{vv~}{ll}{, jj}{, f.}"))
de~la Vallee~Poussin, C.~L. X.~J.
julia> name = "abc";

julia> print(format_name(name, "{vv~}{ll}{, jj}{, f.}"))
abc
julia> name = "Jean-Pierre Hansen";

julia> print(format_name(name, "{ff~}{vv~}{ll}{, jj}"))
Jean-Pierre Hansen
julia> print(format_name(name, "{f.~}{vv~}{ll}{, jj}"))
J.-P. Hansen
julia> name = "F. Phidias Phony-Baloney";

julia> print(format_name(name, "{v{}}{l}"))
P.-B
julia> print(format_name(name, "{v{}}{l.}"))
P.-B.
julia> print(format_name(name, "{v{}}{l{}}"))
PB
```

```@index
Modules=[BibTeXFormat]
Pages = ["style/names.jl"]
```

```@autodocs
Modules=[BibTeXFormat]
Pages = ["style/names.jl"]
```

## Labels

```@index
Modules=[BibTeXFormat]
Pages = ["style/labels.jl"]
```

```@autodocs
Modules=[BibTeXFormat]
Pages = ["style/labels.jl"]
```
