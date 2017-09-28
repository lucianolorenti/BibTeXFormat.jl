# BibTeXFormat

## Markdown example

```julia
using BibTeX
using BibTeXFormat

bibliography      = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"),
                                                     "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
mdoutput          = write_to_string( MarkdownBackend(),formatted_entries)
mdoutput_parsed   = Markdown.parse(mdoutput)
```
###  output
```@eval
using BibTeX
using BibTeXFormat

bibliography = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"),
                                               "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
mdoutput    = write_to_string( MarkdownBackend(),formatted_entries)
mdoutput_parsed = Markdown.parse(mdoutput)
```

## HTML example

```@example
using BibTeX
using BibTeXFormat
bibliography      = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"),
                                                    "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
htmlbackend       = HTMLBackend("uft-8") # No prolog and epilog
write_to_file( htmlbackend ,formatted_entries, "html_test.html")
nothing # hide
```
### output
[Result](html_test.html)

## LaTeX example

```@example
using BibTeX
using BibTeXFormat
bibliography      = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"),
                                                    "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
latexbackend      = LaTeXBackend() # No prolog and epilog
write_to_file( latexbackend ,formatted_entries, "latex_test.aux")
nothing # hide
```

### output
[Result](latex_test.aux)

### Markdown output
```
using BibTeX
using BibTeXFormat

bibliography = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"), "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
latexoutput    = write_to_string( LaTeXBackend(),formatted_entries)
```

## Plain example

```julia
using BibTeX
using BibTeXFormat

bibliography      = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"), "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
mdoutput          = write_to_string( MarkdownBackend(),formatted_entries)
mdoutput_parsed   = Markdown.parse(mdoutput)
```
### Output
```
using BibTeX
using BibTeXFormat

bibliography = Bibliography(readstring(joinpath(Pkg.dir("BibTeXFormat"), "test/Clustering.bib")))
formatted_entries = format_entries(AlphaStyle,bibliography)
mdoutput    = write_to_string( MarkdownBackend(),formatted_entries)
mdoutput_parsed = Markdown.parse(mdoutput)
```
