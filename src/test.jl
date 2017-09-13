using BibTeX
using BibTeXStyle
import BibTeXStyle: Style, Backends
bib = Bibliography(readstring("/home/luciano/fuentes/Documentos/Bibliografia/Clustering.bib"))

c= BibTeXStyle.format_entry(AlphaStyle, "bennett69",BibTeXStyle.transform(bib["bennett69"]))

a =format_entries(AlphaStyle,bib)
f = open("/home/luciano/aa.html","w")
b = BibTeXStyle.write_to_stream( BibTeXStyle.HTMLBackend(),a,f)
close(f)

using BibTeXStyle.Style
a = get_article_template(AlphaStyle,nothing)
 for n in a.children
           format_data(n,nothing)
       end
