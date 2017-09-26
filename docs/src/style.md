
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
## Julia Format

```julia
using BibTeX
using BibTeXFormat

bibliography = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"), "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
```

```@index
Pages    = ["style.jl"]
```

```@autodocs
Modules = [BibTeXFormat]
Pages    = ["style.jl"]
```

## Name formatting

BibTeX-like name formatting.
```jldoctest
julia> import BibTeXFormat.BST: format_name

julia> name = "Charles Louis Xavier Joseph de la Vallee Poussin"
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
