using BibTeX
include("Formatting/Formatting.jl")
using Formatting

bib = Bibliography(readstring("/home/luciano/fuentes/Documentos/Bibliografia/Clustering.bib"))
format_entries(BaseStyle(),bib)
