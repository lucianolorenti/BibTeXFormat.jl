using BibTeX
using BibTeXStyle
import BibTeXStyle: Style, Backends
bib = Bibliography(readstring("/home/luciano/fuentes/Documentos/Bibliografia/Clustering.bib"))
a =format_entries(AlphaStyle,bib)
b = ""
Backends.write_to_stream( Backends.HTML.Backend(),a, b)

using BibTeXStyle.Style
a = get_article_template(AlphaStyle,nothing)
 for n in a.children
           format_data(n,nothing)
       end
