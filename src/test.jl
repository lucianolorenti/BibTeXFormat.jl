using BibTeX
using BibTeXStyle

bib = Bibliography(readstring("/home/luciano/fuentes/Documentos/Bibliografia/Clustering.bib"))
format_entries(BaseStyle(),bib)
