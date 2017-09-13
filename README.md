# BibTeXStyle

´´´
using BibTeX
using BibTeXStyle
import BibTeXStyle: Style, Backends
bib = Bibliography(readstring("/home/luciano/fuentes/Documentos/Bibliografia/Clustering.bib"))

c= BibTeXStyle.format_entry(AlphaStyle, "bennett69",BibTeXStyle.transform(bib["bennett69"]))

a =format_entries(AlphaStyle,bib)
b = write_to_string( BibTeXStyle.HTMLBackend(),a)
´´´

