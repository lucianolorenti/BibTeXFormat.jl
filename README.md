# BibTeXStyle
`BibTeXStyle.jl` is a port of the formatting submodule of the python library [Pybtex!](https://pybtex.org/). Allows to format a bibliography parsed with [BibTeX.jl](https://github.com/bramtayl/BibTeX.jl) and convert it to HTML, LaTeX, or plain text

## Usage mode
```julia
using BibTeX
using BibTeXStyle
bibliobraphy      = Bibliography(readstring("Clustering.bib"))
formatted_entries = format_entries(AlphaStyle,bibliography)
HTMLoutput        = write_to_string( BibTeXStyle.HTMLBackend(),formatted_entries)
```
