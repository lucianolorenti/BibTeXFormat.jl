# BibTeXFormat
`BibTeXFormat.jl` is a port of the formatting submodule of the python library [Pybtex!](https://pybtex.org/). It allows to format a bibliography parsed with [BibTeX.jl](https://github.com/bramtayl/BibTeX.jl) and convert it to HTML, LaTeX, Markdown or plain text

[![](https://img.shields.io/badge/docs-latest-blue.svg)](https://lucianolorenti.github.io/BibTeXFormat.jl/latest)

## Usage mode
```julia
using BibTeX
using BibTeXFormat

bibliography = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"), "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
mdoutput    = write_to_string( MarkdownBackend(),formatted_entries)
```

# Credits
*  Andrey Golovizin [Pybtex!](https://pybtex.org/)
