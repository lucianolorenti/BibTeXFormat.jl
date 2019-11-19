# BibTeXFormat

## Markdown example

```julia
using BibTeX
using BibTeXFormat

open_file(x) = open(joinpath(dirname(pathof(BibTeXFormat)), "../", x ))
bibliography      = Bibliography(read(open_file("test/Clustering.bib"), String))
formatted_entries = format_entries(AlphaStyle,bibliography)
mdoutput          = write_to_string( MarkdownBackend(),formatted_entries)
mdoutput_parsed   = Markdown.parse(mdoutput)
```
###  output
```@eval
using BibTeX
using BibTeXFormat

open_file(x) = open(joinpath(dirname(pathof(BibTeXFormat)), "../", x ))
bibliography      = Bibliography(read(open_file("test/Clustering.bib"), String))
formatted_entries = format_entries(AlphaStyle,bibliography)
mdoutput    = write_to_string( MarkdownBackend(),formatted_entries)
mdoutput_parsed = Markdown.parse(mdoutput)
```

## HTML example

```@example
using BibTeX
using BibTeXFormat
open_file(x) = open(joinpath(dirname(pathof(BibTeXFormat)), "../", x))
bibliography      = Bibliography(read(open_file("test/Clustering.bib"), String))
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
open_file(x) = open(joinpath(dirname(pathof(BibTeXFormat)), "../", x))
bibliography      = Bibliography(read(open_file("test/Clustering.bib"), String))
formatted_entries = format_entries(AlphaStyle,bibliography)
latexbackend      = LaTeXBackend() # No prolog and epilog
write_to_file( latexbackend ,formatted_entries, "latex_test.aux")
nothing # hide
```

### output
[Result](latex_test.aux)

## Plain text example

```@example
using BibTeX
using BibTeXFormat
open_file(x) = open(joinpath(dirname(pathof(BibTeXFormat)), "../", x))
bibliography      = Bibliography(read(open_file("test/Clustering.bib"), String))
formatted_entries = format_entries(AlphaStyle,bibliography)
write_to_file( TextBackend(),formatted_entries, "text_test.txt")
```

### output
[Result](text_test.txt)
