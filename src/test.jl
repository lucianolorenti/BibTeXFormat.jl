using BibTeX
using BibTeXStyle

bib = Bibliography(readstring("/home/luciano/fuentes/Documentos/Bibliografia/Clustering.bib"))
a = format_entries(Style.AlphaStyle,bib)
println(a)
