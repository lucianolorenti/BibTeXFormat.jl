var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#BibTeXFormat-1",
    "page": "Home",
    "title": "BibTeXFormat",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Markdown-example-1",
    "page": "Home",
    "title": "Markdown example",
    "category": "section",
    "text": "using BibTeX\nusing BibTeXFormat\n\nbibliography      = Bibliography(readstring(joinpath(Pkg.dir(\"BibTeXFormat\"),\n                                                     \"test/Clustering.bib\")))\nformatted_entries = format_entries(AlphaStyle,bibliography)\nmdoutput          = write_to_string( MarkdownBackend(),formatted_entries)\nmdoutput_parsed   = Markdown.parse(mdoutput)"
},

{
    "location": "index.html#output-1",
    "page": "Home",
    "title": "output",
    "category": "section",
    "text": "using BibTeX\nusing BibTeXFormat\n\nbibliography = Bibliography(readstring(joinpath(Pkg.dir(\"BibTeXFormat\"),\n                                               \"test/Clustering.bib\")))\nformatted_entries = format_entries(AlphaStyle,bibliography)\nmdoutput    = write_to_string( MarkdownBackend(),formatted_entries)\nmdoutput_parsed = Markdown.parse(mdoutput)"
},

{
    "location": "index.html#HTML-example-1",
    "page": "Home",
    "title": "HTML example",
    "category": "section",
    "text": "using BibTeX\nusing BibTeXFormat\nbibliography      = Bibliography(readstring(joinpath(Pkg.dir(\"BibTeXFormat\"),\n                                                    \"test/Clustering.bib\")))\nformatted_entries = format_entries(AlphaStyle,bibliography)\nhtmlbackend       = HTMLBackend(\"uft-8\") # No prolog and epilog\nwrite_to_file( htmlbackend ,formatted_entries, \"html_test.html\")\nnothing # hide"
},

{
    "location": "index.html#output-2",
    "page": "Home",
    "title": "output",
    "category": "section",
    "text": "Result"
},

{
    "location": "index.html#LaTeX-example-1",
    "page": "Home",
    "title": "LaTeX example",
    "category": "section",
    "text": "using BibTeX\nusing BibTeXFormat\nbibliography      = Bibliography(readstring(joinpath(Pkg.dir(\"BibTeXFormat\"),\n                                                    \"test/Clustering.bib\")))\nformatted_entries = format_entries(AlphaStyle,bibliography)\nlatexbackend      = LaTeXBackend() # No prolog and epilog\nwrite_to_file( latexbackend ,formatted_entries, \"latex_test.aux\")\nnothing # hide"
},

{
    "location": "index.html#output-3",
    "page": "Home",
    "title": "output",
    "category": "section",
    "text": "Result"
},

{
    "location": "index.html#Plain-text-example-1",
    "page": "Home",
    "title": "Plain text example",
    "category": "section",
    "text": "using BibTeX\nusing BibTeXFormat\n\nbibliography      = Bibliography(readstring(joinpath(Pkg.dir(\"BibTeXFormat\"), \"test/Clustering.bib\")))\nformatted_entries = format_entries(AlphaStyle,bibliography)\nwrite_to_file( TextBackend(),formatted_entries, \"text_test.txt\")"
},

{
    "location": "index.html#output-4",
    "page": "Home",
    "title": "output",
    "category": "section",
    "text": "Result"
},

{
    "location": "style.html#",
    "page": "Style",
    "title": "Style",
    "category": "page",
    "text": ""
},

{
    "location": "style.html#Style-1",
    "page": "Style",
    "title": "Style",
    "category": "section",
    "text": ""
},

{
    "location": "style.html#Julia-Format-1",
    "page": "Style",
    "title": "Julia Format",
    "category": "section",
    "text": ""
},

{
    "location": "style.html#BibTeXFormat.AlphaStyle",
    "page": "Style",
    "title": "BibTeXFormat.AlphaStyle",
    "category": "Constant",
    "text": "Alpha Style\n\nConfig(label_style = AlphaLabelStyle(),sorting_style = AuthorYearTitleSortingStyle())\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.format_entries-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.BaseStyle",
    "page": "Style",
    "title": "BibTeXFormat.format_entries",
    "category": "Method",
    "text": "function format_entries(b::T, entries::Dict) where T <: BaseStyle\n\nFormat a Dict of entries with a given style b::T where T <: BaseStyle\n\nusing BibTeX\nusing BibTeXFormat\nbibliography      = Bibliography(readstring(\"test/Clustering.bib\"))\nformatted_entries = format_entries(AlphaStyle,bibliography)\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.format_entry-Union{Tuple{T,Any,BibTeX.Citation}, Tuple{T}} where T<:BibTeXFormat.BaseStyle",
    "page": "Style",
    "title": "BibTeXFormat.format_entry",
    "category": "Method",
    "text": "function format_entry(b::T, label, entry::Citation) where T <: BaseStyle\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.format_entry-Union{Tuple{T,Any,Dict{String,Any}}, Tuple{T}} where T<:BibTeXFormat.BaseStyle",
    "page": "Style",
    "title": "BibTeXFormat.format_entry",
    "category": "Method",
    "text": "function format_entry(b::T, label, entry) where T <: BaseStyle\n\nFormat an entry with a given style b::T where T <: BaseStyle\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.PlainAlphaStyle",
    "page": "Style",
    "title": "BibTeXFormat.PlainAlphaStyle",
    "category": "Constant",
    "text": "PlainAlphaStyle\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.UNSRTAlphaStyle",
    "page": "Style",
    "title": "BibTeXFormat.UNSRTAlphaStyle",
    "category": "Constant",
    "text": "UNSRTAlphaStyle\n\nConfig(label_style = AlphaLabelStyle())\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.expand_wildcard_citations-Tuple{Any,Any}",
    "page": "Style",
    "title": "BibTeXFormat.expand_wildcard_citations",
    "category": "Method",
    "text": "Expand wildcard citations (citation{*} in .aux file).\n\njulia> using BibTeX\n\njulia> import BibTeXFormat: expand_wildcard_citations\n\njulia> data = Bibliography(\"\", Dict{String,Citation}(\"uno\"=>Citation{:article}(),\"dos\"=>Citation{:article}(),\"tres\"=>Citation{:article}(),	\"cuatro\"=>Citation{:article}()));\n\njulia> expand_wildcard_citations(data, [])\n0-element Array{Any,1}\n\njulia> print(expand_wildcard_citations(data, [\"*\"]))\nAny[\"tres\", \"dos\", \"uno\", \"cuatro\"]\njulia> print(expand_wildcard_citations(data, [\"uno\", \"*\"]))\nAny[\"uno\", \"tres\", \"dos\", \"cuatro\"]\njulia> print(expand_wildcard_citations(data, [\"dos\", \"*\"]))\nAny[\"dos\", \"tres\", \"uno\", \"cuatro\"]\njulia> print(expand_wildcard_citations(data, [\"*\", \"uno\"]))\nAny[\"tres\", \"dos\", \"uno\", \"cuatro\"]\njulia> print(expand_wildcard_citations(data, [\"*\", \"DOS\"]))\nAny[\"tres\", \"dos\", \"uno\", \"cuatro\"]\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.format_bibliography-Union{Tuple{T,BibTeX.Bibliography,Any}, Tuple{T,BibTeX.Bibliography}, Tuple{T}} where T<:BibTeXFormat.BaseStyle",
    "page": "Style",
    "title": "BibTeXFormat.format_bibliography",
    "category": "Method",
    "text": "function format_bibliography(self::T, bib_data, citations=nothing) where T<:BaseStyle\n\nFormat bibliography entries with the given keys Params:\n\nself::T where T<:BaseStyle. The style\nbib_data BibTeX.Bibliography\nparam citations: A list of citation keys.\n\nusing BibTeX\nusing BibTeXFormat\nbibliography      = Bibliography(readstring(\"test/Clustering.bib\"))\n\nformatted_entries = format_entries(AlphaStyle,bibliography)\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.get_crossreferenced_citations-Tuple{Any,Any}",
    "page": "Style",
    "title": "BibTeXFormat.get_crossreferenced_citations",
    "category": "Method",
    "text": "Get cititations not cited explicitly but referenced by other citations.\n\njulia> using BibTeX\n\njulia> import BibTeXFormat: get_crossreferenced_citations\n\njulia> data = Bibliography(\"\", Dict{String,Citation}(\"main_article\"=>Citation{:article}(Dict(\"crossref\"=>\"xrefd_article\")),\"xrefd_article\"=>Citation{:article}()));\n\njulia> print(get_crossreferenced_citations(data, [], min_crossrefs=1))\nAny[]\njulia> print(get_crossreferenced_citations(data, [\"main_article\"], min_crossrefs=1))\nAny[\"xrefd_article\"]\njulia> print(get_crossreferenced_citations(data,[\"Main_article\"], min_crossrefs=1))\nAny[\"xrefd_article\"]\njulia> print(get_crossreferenced_citations(data, [\"main_article\"], min_crossrefs=2))\nAny[]\njulia> print(get_crossreferenced_citations(data, [\"xrefd_arcicle\"], min_crossrefs=1))\nAny[]\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.transform-Tuple{BibTeX.Citation,Any}",
    "page": "Style",
    "title": "BibTeXFormat.transform",
    "category": "Method",
    "text": "function transform(e::Citation, label)\n\nAdd some information to a BibTeX.Citation.\n\n\n\n"
},

{
    "location": "style.html#Example-1",
    "page": "Style",
    "title": "Example",
    "category": "section",
    "text": "using BibTeX\nusing BibTeXFormat\n\nbibliography = Bibliography(readstring(joinpath(Pkg.dir(\"BibTeXFormat\"),\n                             \"test/Clustering.bib\")))\nformatted_entries = format_entries(AlphaStyle,bibliography)\nHTMLoutput        = write_to_string( HTMLBackend(),formatted_entries )Pages    = [\"style.jl\"]Modules = [BibTeXFormat]\nPages    = [\"style.jl\"]"
},

{
    "location": "style.html#BST-1",
    "page": "Style",
    "title": "BST",
    "category": "section",
    "text": "using BibTeX\nusing BibTeXFormat\nbibliography = Bibliography(readstring(joinpath(Pkg.dir(\"BibTeXFormat\"), \"test/Clustering.bib\")))\nstyle        = BST.parse_file(joinpath(Pkg.dir(\"BibTeXFormat\"),\"test/format/apacite.bst\"))\nlatexOutput = format_entries(style, bibliography)"
},

{
    "location": "style.html#BibTeXFormat.BST.Style",
    "page": "Style",
    "title": "BibTeXFormat.BST.Style",
    "category": "Type",
    "text": "type Style <: BaseStyle\n\nA Style obtained from a .bst file\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.BST.parse_file-Tuple{String}",
    "page": "Style",
    "title": "BibTeXFormat.BST.parse_file",
    "category": "Method",
    "text": "function parse_file(filename::String)\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.BST.parse_string-Tuple{String}",
    "page": "Style",
    "title": "BibTeXFormat.BST.parse_string",
    "category": "Method",
    "text": "function parse_string(content::String)\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.BST.run",
    "page": "Style",
    "title": "BibTeXFormat.BST.run",
    "category": "Function",
    "text": "function run(self, citations, bib_files, min_crossrefs):\n\nRun bst script and return formatted bibliography.\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.BST.strip_comment-Tuple{Any}",
    "page": "Style",
    "title": "BibTeXFormat.BST.strip_comment",
    "category": "Method",
    "text": "Strip the commented part of the line.\" ´´´jldoctest julia> print(strip_comment(\"a normal line\")) a normal line julia> print(strip_comment(\"%\"))\n\njulia> print(strip_comment(\"%comment\"))\n\njulia> print(strip_comment(\"trailing%\")) trailing julia> print(strip_comment(\"a normal line% and a comment\")) a normal line julia> print(strip_comment(\"\"100% compatibility\" is a myth\")) \"100% compatibility\" is a myth julia> print(strip_comment(\"\"100% compatibility\" is a myth% or not?\")) \"100% compatibility\" is a myth ´´´\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.format_bibliography",
    "page": "Style",
    "title": "BibTeXFormat.format_bibliography",
    "category": "Function",
    "text": "function format_bibliography(self::Style, bib_data, citations=nothing)\n\nFormat bibliography entries with the given keys\n\nParams:\n\nstyle::Style. The BST style\nbib_data\nparam citations: A list of citation keys.\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.format_entries-Tuple{BibTeXFormat.BST.Style,Any}",
    "page": "Style",
    "title": "BibTeXFormat.format_entries",
    "category": "Method",
    "text": "function format_entries(b::Style, entries::Dict)\n\nFormat a Dict of entries with a given style b::Style\n\nusing BibTeX\nusing BibTeXFormat\nbibliography      = Bibliography(readstring(\"test/Clustering.bib\"))\nstyle        = BST.parse_file(joinpath(Pkg.dir(\"BibTeXFormat\"),\"test/format/apacite.bst\"))\nformatted_entries = format_entries(style, bibliography)\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.BST.NameFormat",
    "page": "Style",
    "title": "BibTeXFormat.BST.NameFormat",
    "category": "Type",
    "text": "struct NameFormat\n\nBibTeX name format string.\n\njulia> import BibTeXFormat.BST: NameFormat, NamePart\n\njulia> f = NameFormat(\"{ff~}{vv~}{ll}{, jj}\");\n\njulia> f.parts == [ NamePart([\"\", \"ff\", nothing, \"\"]),  NamePart([\"\", \"vv\", nothing, \"\"]),  NamePart([\"\", \"ll\", nothing, \"\"]),  NamePart([\", \", \"jj\", nothing, \"\"]) ]\ntrue\n\njulia> f = NameFormat(\"{{ }ff~{ }}{vv~{- Test text here -}~}{ll}{, jj}\");\n\njulia> f.parts == [NamePart([\"{ }\", \"ff\", nothing, \"~{ }\"]), NamePart([\"\", \"vv\", nothing, \"~{- Test text here -}\"]), NamePart([\"\", \"ll\", nothing, \"\"]),  NamePart([\", \", \"jj\", nothing, \"\"]) ]\ntrue\n\njulia> f = NameFormat(\"abc def {f~} xyz {f}?\");\n\njulia> f.parts == [\"abc def \", NamePart([\"\", \"f\", nothing, \"\"]), \" xyz \", NamePart([\"\", \"f\", nothing, \"\"]),  \"?\" ]\ntrue\n\njulia> f = NameFormat(\"{{abc}{def}ff~{xyz}{#@\\$}}\");\n\njulia> f.parts == [NamePart([\"{abc}{def}\", \"ff\", nothing, \"~{xyz}{#@\\$}\"])]\ntrue\n\njulia> f = NameFormat(\"{{abc}{def}ff{xyz}{#@\\${}{sdf}}}\");\n\njulia> f.parts == [NamePart([\"{abc}{def}\", \"ff\", \"xyz\", \"{#@\\${}{sdf}}\"])]\ntrue\n\njulia> f = NameFormat(\"{f.~}\");\n\njulia> f.parts == [NamePart([\"\", \"f\", nothing, \".\"])]\ntrue\n\njulia> f = NameFormat(\"{f~.}\");\n\njulia> f.parts == [NamePart([\"\", \"f\", nothing, \"~.\"])]\ntrue\n\njulia> f = NameFormat(\"{f{.}~}\");\n\njulia> f.parts == [NamePart([\"\", \"f\", \".\", \"\"])]\ntrue\n\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.BST.bst_join",
    "page": "Style",
    "title": "BibTeXFormat.BST.bst_join",
    "category": "Function",
    "text": "function bst_join(words, tie=\"~\", space=\" \")\nend\nJoin some words, inserting ties (~) when nessessary.\n    Ties are inserted:\n    - after the first word, if it is short\n    - before the last word\n    Otherwise space is inserted.\n    Should produce the same oubput as BibTeX.\n\njldoctest julia> import BibTeXFormat.BST: bst_join\n\njulia> print(bst_join([\"a\", \"long\", \"long\", \"road\"])) a~long long~road\n\njulia> print(bst_join([\"very\", \"long\", \"phrase\"])) very long~phrase\n\njulia> print(bst_join([\"De\", \"La\"])) De~La ```\n\n\n\n"
},

{
    "location": "style.html#References-1",
    "page": "Style",
    "title": "References",
    "category": "section",
    "text": "Modules=[BibTeXFormat.BST]\nPages = [\"style/bst/bst.jl\", \"style/bst/interpreter.jl\", \"style/bst/names.jl\"]Modules=[BibTeXFormat.BST]\nPages = [\"style/bst/bst.jl\", \"style/bst/interpreter.jl\", \"style/bst/names.jl\"]"
},

{
    "location": "style.html#BibTeXFormat.format",
    "page": "Style",
    "title": "BibTeXFormat.format",
    "category": "Function",
    "text": "Format names similarly to {ff~}{vv~}{ll}{, jj} in BibTeX.\n\n\njulia> import BibTeXFormat: Person, render_as, PlainNameStyle, format\n\njulia> import BibTeXFormat.TemplateEngine\n\njulia> name = Person(\"Charles Louis Xavier Joseph de la Vall{\\'e}e Poussin\");\n\njulia> plain = PlainNameStyle();\n\njulia> render_as(TemplateEngine.format(format(plain, name)),\"latex\")\n\"Charles Louis Xavier~Joseph de~la Vall{é}e~Poussin\"\n\njulia> render_as(TemplatEngine.format(format(plain, name),\"html\"))\n\"Charles Louis Xavier&nbsp;Joseph de&nbsp;la Vall<span class=\"bibtex-protected\">é</span>e&nbsp;Poussin\"\n\njulia> render_as(TemplateEngine.format(format(plain,name, true)), \"latex\")\n\"C.~L. X.~J. de~la Vall{é}e~Poussin\"\n\njulia> render_as(TemplateEngine.format(format(plain, name, true)),\"html\")\n\"C.&nbsp;L. X.&nbsp;J. de&nbsp;la Vall<span class=\"bibtex-protected\">é</span>e&nbsp;Poussin\"\n\njulia> name = Person(first=\"First\", last=\"Last\", middle=\"Middle\");\n\njulia> render_as(TemplateEngine.format(format(plain, name)),\"latex\")\n\"First~Middle Last\"\n\njulia> render_as(TemplateEngine.format(format(plain,name, true)),\"latex\")\n\"F.~M. Last\"\n\njulia> render_as(TemplateEngine.format(format(plain,Person(\"de Last, Jr., First Middle\"))),\"latex\")\n\"First~Middle de~Last, Jr.\"\n\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.format",
    "page": "Style",
    "title": "BibTeXFormat.format",
    "category": "Function",
    "text": "function format(self::LastFirstNameStyle, person, abbr=false)\n\nFormat names similarly to {vv~}{ll}{, jj}{, f.} in BibTeX.\n\njulia> import BibTeXFormat: Person, render_as, LastFirstNameStyle, format\n\njulia> import BibTeXFormat.TemplateEngine\n\njulia> name = Person(\"Charles Louis Xavier Joseph de la Vall{\\\\'e}e Poussin\");\n\njulia> lastfirst = LastFirstNameStyle();\n\njulia> render_as(TemplateEngine.format(format(lastfirst,name)),\"latex\")\n\"de~la Vall{é}e~Poussin, Charles Louis Xavier~Joseph\"\n\njulia> render_as(TemplateEngine.format(format(lastfirst,name)),\"html\")\n\"de&nbsp;la Vall<span class=\"bibtex-protected\">é</span>e&nbsp;Poussin, Charles Louis Xavier&nbsp;Joseph\"\n\njulia> render_as(TemplateEngine.format(format(lastfirst,name, true)),\"latex\")\n\"de~la Vall{é}e~Poussin, C.~L. X.~J.\"\n\njulia> print(render_as(TemplateEngine.format(format(lastfirst,name, true)),\"html\"))\nde&nbsp;la Vall<span class=\"bibtex-protected\">é</span>e&nbsp;Poussin, C.&nbsp;L. X.&nbsp;J.\n\njulia> name = Person(first=\"First\", last=\"Last\", middle=\"Middle\");\n\njulia> render_as(TemplateEngine.format(format(lastfirst,name)),\"latex\")\n\"Last, First~Middle\"\n\njulia> render_as(TemplateEngine.format(format(lastfirst,name, true)),\"latex\")\n\"Last, F.~M.\"\n\n\n\n\n"
},

{
    "location": "style.html#Name-formatting-1",
    "page": "Style",
    "title": "Name formatting",
    "category": "section",
    "text": "BibTeX-like name formatting.julia> import BibTeXFormat.BST: format_name\n\njulia> name = \"Charles Louis Xavier Joseph de la Vallee Poussin\";\n\njulia> print(format_name(name, \"{vv~}{ll}{, jj}{, f.}\"))\nde~la Vallee~Poussin, C.~L. X.~J.\njulia> name = \"abc\";\n\njulia> print(format_name(name, \"{vv~}{ll}{, jj}{, f.}\"))\nabc\njulia> name = \"Jean-Pierre Hansen\";\n\njulia> print(format_name(name, \"{ff~}{vv~}{ll}{, jj}\"))\nJean-Pierre Hansen\njulia> print(format_name(name, \"{f.~}{vv~}{ll}{, jj}\"))\nJ.-P. Hansen\njulia> name = \"F. Phidias Phony-Baloney\";\n\njulia> print(format_name(name, \"{v{}}{l}\"))\nP.-B\njulia> print(format_name(name, \"{v{}}{l.}\"))\nP.-B.\njulia> print(format_name(name, \"{v{}}{l{}}\"))\nPBModules=[BibTeXFormat]\nPages = [\"style/names.jl\"]Modules=[BibTeXFormat]\nPages = [\"style/names.jl\"]"
},

{
    "location": "style.html#BibTeXFormat._strip_nonalnum-Tuple{Any}",
    "page": "Style",
    "title": "BibTeXFormat._strip_nonalnum",
    "category": "Method",
    "text": "Strip all non-alphanumerical characters from a list of strings.\n\njulia> import BibTeXFormat: _strip_nonalnum\n\njulia> print(_strip_nonalnum([\"ÅA. B. Testing 12+}[.@~_\", \" 3%\"]))\nAABTesting123\n\n\n\n\n"
},

{
    "location": "style.html#Labels-1",
    "page": "Style",
    "title": "Labels",
    "category": "section",
    "text": "Modules=[BibTeXFormat]\nPages = [\"style/labels.jl\"]Modules=[BibTeXFormat]\nPages = [\"style/labels.jl\"]"
},

{
    "location": "backends.html#",
    "page": "Backends",
    "title": "Backends",
    "category": "page",
    "text": ""
},

{
    "location": "backends.html#BibTeXFormat.render_as-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.BaseText",
    "page": "Backends",
    "title": "BibTeXFormat.render_as",
    "category": "Method",
    "text": "function render_as(self::T, backend_name) where T<:BaseText\n\nRender BaseText into markup. This is a wrapper method that loads a formatting backend plugin and calls :py render(:BaseText). backend_name is  the name of the output backend ( \"latex\",\"html\", \"markdown\", \"text\").\n\njulia> import BibTeXFormat.RichTextElements: RichText, Tag\n\njulia> import BibTeXFormat: render_as\n\njulia> text = RichText(\"Longcat is \", Tag(\"em\", \"looooooong\"), \"!\");\n\njulia> print(render_as(text, \"html\"))\nLongcat is <em>looooooong</em>!\njulia> print(render_as(text, \"latex\"))\nLongcat is \\emph{looooooong}!\njulia> print(render_as(text, \"text\"))\nLongcat is looooooong!\n\n\n\n\n"
},

{
    "location": "backends.html#BibTeXFormat.BaseBackend",
    "page": "Backends",
    "title": "BibTeXFormat.BaseBackend",
    "category": "Type",
    "text": "This is the base type for the backends. We encourage you to implement as many of the symbols and tags as possible when you create a new plugin.\n\nsymbols[\"ndash\"]    : Used to separate pages\nsymbols[\"newblock\"] : Used to separate entries in the bibliography\nsymbols[\"bst_script\"]      : A non-breakable space\ntags[\"\"em']   : emphasize text\ntags[\"strong\"]: emphasize text even more\ntags[\"i\"]     : italicize text, not semantic\ntags[\"b\"]     : embolden text, not semantic\ntags[\"tt\"]    : typewrite text, not semantic\n\n\n\n"
},

{
    "location": "backends.html#BibTeXFormat.format-Union{Tuple{T,BibTeXFormat.RichTextElements.Protected,Any}, Tuple{T}} where T<:BibTeXFormat.BaseBackend",
    "page": "Backends",
    "title": "BibTeXFormat.format",
    "category": "Method",
    "text": "function format(self::T, t::Protected, text) where T<:BaseBackend\n\nFormat a \"protected\" piece of text.\n\nIn LaTeX backend, it is formatted as a {braced group}. Most other backends would just output the text as-is.\n\n\n\n"
},

{
    "location": "backends.html#BibTeXFormat.format-Union{Tuple{T,String}, Tuple{T}} where T<:BibTeXFormat.BaseBackend",
    "page": "Backends",
    "title": "BibTeXFormat.format",
    "category": "Method",
    "text": "function format(self::T, str::String) where T<:BaseBackend\n\nFormat the given string str_. The default implementation simply returns the string ad verbatim. Override this method for non-string backends.\n\n\n\n"
},

{
    "location": "backends.html#BibTeXFormat.render_sequence-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.BaseBackend",
    "page": "Backends",
    "title": "BibTeXFormat.render_sequence",
    "category": "Method",
    "text": "function render_sequence(self::T, rendered_list) where T <:BaseBackend\n\nRender a sequence of rendered Text objects. The default implementation simply concatenates the strings in rendered_list. Override this method for non-string backends.\n\n\n\n"
},

{
    "location": "backends.html#Backends-1",
    "page": "Backends",
    "title": "Backends",
    "category": "section",
    "text": "Pages    = [\"backends/backends.jl\"]Modules = [BibTeXFormat]\nPages    = [\"backends/backends.jl\"]"
},

{
    "location": "backends.html#BibTeXFormat.HTMLBackend",
    "page": "Backends",
    "title": "BibTeXFormat.HTMLBackend",
    "category": "Type",
    "text": "struct HTMLBackend <: BaseBackend\n\njulia> import BibTeXFormat.RichTextElements: RichText, Tag, TextSymbol\n\njulia> import BibTeXFormat: render, HTMLBackend\n\njulia> print(render(Tag(\"em\", RichText(\"Ð›.:\", TextSymbol(\"nbsp\"), \"<<Ð¥Ð¸Ð¼Ð¸Ñ>>\")),HTMLBackend()))\n<em>Ð›.:&nbsp;&lt;&lt;Ð¥Ð¸Ð¼Ð¸Ñ&gt;&gt;</em>\n\n\n\n"
},

{
    "location": "backends.html#HTML-1",
    "page": "Backends",
    "title": "HTML",
    "category": "section",
    "text": "Pages    = [\"backends/html.jl\"]Modules = [BibTeXFormat]\nPages    = [\"backends/html.jl\"]"
},

{
    "location": "backends.html#BibTeXFormat.LaTeXBackend",
    "page": "Backends",
    "title": "BibTeXFormat.LaTeXBackend",
    "category": "Type",
    "text": "LaTeX output backend.\n\njulia> import BibTeXFormat: LaTeXBackend, render\n\njulia> import BibTeXFormat.RichTextElements: Tag, HRef\n\njulia> latex = LaTeXBackend();\n\njulia> print(render(Tag(\"em\", \"\"),latex))\n\njulia> print(render(Tag(\"em\", \"Non-\", \"empty\"),latex))\n\\emph{Non-empty}\njulia> print(render(HRef(\"/\", \"\"),latex))\n\njulia> print(render(HRef(\"/\", \"Non-\", \"empty\"),latex))\n\\href{/}{Non-empty}\njulia> print(render(HRef(\"http://example.org/\", \"http://example.org/\"),latex))\n\\url{http://example.org/}\n\n\n\n"
},

{
    "location": "backends.html#BibTeXFormat.format-Tuple{BibTeXFormat.LaTeXBackend,BibTeXFormat.RichTextElements.Protected,Any}",
    "page": "Backends",
    "title": "BibTeXFormat.format",
    "category": "Method",
    "text": "function format(self::LaTeXBackend, p::Protected, text)\n\njulia> import BibTeXFormat.RichTextElements: Protected\n\njulia> import BibTeXFormat: render_as\n\njulia> print(render_as(Protected(\"CTAN\"), \"latex\"))\n{CTAN}\n\n\n\n"
},

{
    "location": "backends.html#LaTeX-1",
    "page": "Backends",
    "title": "LaTeX",
    "category": "section",
    "text": "Pages    = [\"backends/latex.jl\"]Modules = [BibTeXFormat]\nPages    = [\"backends/latex.jl\"]"
},

{
    "location": "backends.html#BibTeXFormat.MarkdownBackend",
    "page": "Backends",
    "title": "BibTeXFormat.MarkdownBackend",
    "category": "Type",
    "text": "A backend to support markdown output. It implements the same features as the HTML backend.\n\nIn addition to that, you can use the keyword php_extra=True to enable the definition list extension of php-markdown. The default is not to use it, since we cannot be sure that this feature is implemented on all systems.\n\nMore information: http://www.michelf.com/projects/php-markdown/extra/#def-list\n\n\n\n"
},

{
    "location": "backends.html#BibTeXFormat.format-Tuple{BibTeXFormat.MarkdownBackend,String}",
    "page": "Backends",
    "title": "BibTeXFormat.format",
    "category": "Method",
    "text": "Format the given string str_. Escapes special markdown control characters.\n\n\n\n"
},

{
    "location": "backends.html#Markdown-1",
    "page": "Backends",
    "title": "Markdown",
    "category": "section",
    "text": "Pages    = [\"backends/markdown.jl\"]Modules = [BibTeXFormat]\nPages    = [\"backends/markdown.jl\"]"
},

{
    "location": "backends.html#Text-1",
    "page": "Backends",
    "title": "Text",
    "category": "section",
    "text": "Pages    = [\"backends/plaintext.jl\"]Modules = [BibTeXFormat]\nPages    = [\"backends/plaintext.jl\"]"
},

{
    "location": "person.html#",
    "page": "Person",
    "title": "Person",
    "category": "page",
    "text": ""
},

{
    "location": "person.html#BibTeXFormat.Person",
    "page": "Person",
    "title": "BibTeXFormat.Person",
    "category": "Type",
    "text": "A person or some other person-like entity.\n\njulia> import BibTeXFormat.Person;\n\njulia> knuth = Person(\"Donald E. Knuth\");\n\njulia> knuth.first_names\n1-element Array{String,1}:\n \"Donald\"\n\njulia> knuth.middle_names\n1-element Array{String,1}:\n \"E.\"\n\njulia> knuth.last_names\n1-element Array{String,1}:\n \"Knuth\"\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat.Person",
    "page": "Person",
    "title": "BibTeXFormat.Person",
    "category": "Type",
    "text": "Construct a Person from a full name string . It will be parsed and split into separate first, last, middle, pre-last and lineage name parst.\n\nSupported name formats are:\n\nvon Last, First\nvon Last, Jr, First\nFirst von Last\n\n(see BibTeX manual for explanation)\n\n\n\n"
},

{
    "location": "person.html#Base.convert-Tuple{Type{String},BibTeXFormat.Person}",
    "page": "Person",
    "title": "Base.convert",
    "category": "Method",
    "text": "von Last, Jr, First\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat._parse_string-Tuple{BibTeXFormat.Person,String}",
    "page": "Person",
    "title": "BibTeXFormat._parse_string",
    "category": "Method",
    "text": "Extract various parts of the name from a string.\n\njulia> import BibTeXFormat: Person\n\njulia> p = Person(\"Avinash K. Dixit\");\n\njulia> p.first_names\n1-element Array{String,1}:\n \"Avinash\"\n\njulia> p.middle_names\n1-element Array{String,1}:\n \"K.\"\n\njulia> p.prelast_names\n0-element Array{String,1}\n\njulia> p.last_names\n1-element Array{String,1}:\n \"Dixit\"\n\njulia> p.lineage_names\n0-element Array{String,1}\n\njulia> convert(String,p)\n\"Dixit, Avinash K.\"\n\njulia> p == Person(convert(String,p))\ntrue\n\njulia> p = Person(\"Dixit, Jr, Avinash K. \");\n\njulia> p.first_names\n1-element Array{String,1}:\n \"Avinash\"\n\njulia> p.middle_names\n1-element Array{String,1}:\n \"K.\"\n\njulia> print(p.prelast_names)\nString[]\njulia> print(p.last_names)\nString[\"Dixit\"]\njulia> print(p.lineage_names)\nString[\"Jr\"]\njulia> print(convert(String,p))\nDixit, Jr, Avinash K.\njulia> p == Person(convert(String,p))\ntrue\n\njulia> p = Person(\"abc\");\n\njulia> print(p.first_names, p.middle_names, p.prelast_names, p.last_names, p.lineage_names)\nString[]String[]String[]String[\"abc\"]String[]\njulia> p = Person(\"Viktorov, Michail~Markovitch\");\n\njulia> print(p.first_names, p.middle_names, p.prelast_names, p.last_names, p.lineage_names)\nString[\"Michail\"]String[\"Markovitch\"]String[]String[\"Viktorov\"]String[]\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat.bibtex_first_names-Tuple{BibTeXFormat.Person}",
    "page": "Person",
    "title": "BibTeXFormat.bibtex_first_names",
    "category": "Method",
    "text": "A list of first and middle names together. (BibTeX treats all middle names as first.)\n\njulia> import BibTeXFormat: Person, bibtex_first_names\n\njulia> knuth = Person(\"Donald E. Knuth\");\n\njulia> bibtex_first_names(knuth)\n2-element Array{String,1}:\n \"Donald\"\n \"E.\"\n\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat.get_part",
    "page": "Person",
    "title": "BibTeXFormat.get_part",
    "category": "Function",
    "text": "Get a list of name parts by type.\n\njulia> import BibTeXFormat: Person, get_part;\n\njulia> knuth = Person(\"Donald E. Knuth\");\n\njulia> get_part(knuth,\"first\")\n1-element Array{String,1}:\n \"Donald\"\n\njulia> get_part(knuth,\"last\")\n1-element Array{String,1}:\n \"Knuth\"\n\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat.rich_first_names-Tuple{BibTeXFormat.Person}",
    "page": "Person",
    "title": "BibTeXFormat.rich_first_names",
    "category": "Method",
    "text": "A list of first names converted to :ref:rich text <rich-text>.\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat.rich_last_names-Tuple{BibTeXFormat.Person}",
    "page": "Person",
    "title": "BibTeXFormat.rich_last_names",
    "category": "Method",
    "text": "A list of last names converted to :ref:rich text <rich-text>.\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat.rich_lineage_names-Tuple{BibTeXFormat.Person}",
    "page": "Person",
    "title": "BibTeXFormat.rich_lineage_names",
    "category": "Method",
    "text": "A list of lineage (aka Jr) name parts converted to :ref:rich text <rich-text>.\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat.rich_middle_names-Tuple{BibTeXFormat.Person}",
    "page": "Person",
    "title": "BibTeXFormat.rich_middle_names",
    "category": "Method",
    "text": "A list of middle names converted to :ref:rich text <rich-text>.\n\n\n\n"
},

{
    "location": "person.html#BibTeXFormat.rich_prelast_names-Tuple{BibTeXFormat.Person}",
    "page": "Person",
    "title": "BibTeXFormat.rich_prelast_names",
    "category": "Method",
    "text": "A list of pre-last (aka von) name parts converted to :ref:rich text <rich-text>.\n\n\n\n"
},

{
    "location": "person.html#Person-1",
    "page": "Person",
    "title": "Person",
    "category": "section",
    "text": "Pages    = [\"person.jl\"]Modules = [BibTeXFormat]\nPages    = [\"person.jl\"]"
},

{
    "location": "richtextelements.html#",
    "page": "Rich Text Elements",
    "title": "Rich Text Elements",
    "category": "page",
    "text": ""
},

{
    "location": "richtextelements.html#RichTextElements-1",
    "page": "Rich Text Elements",
    "title": "RichTextElements",
    "category": "section",
    "text": "DocTestSetup = quote\nimport BibTeXFormat.RichTextElements: RichText, Tag, append, render_as, add_period, capfirst,\n                    capitalize, typeinfo, create_similar, HRef,\n                    merge_similar, render_as, Protected,\n                    RichString\nend"
},

{
    "location": "richtextelements.html#Description-1",
    "page": "Rich Text Elements",
    "title": "Description",
    "category": "section",
    "text": "(simple but) rich text formatting toolsjulia> import BibTeXFormat: RichText, Tag, render_as\n\njulia> import BibTeXFormat.RichTextElements: add_period, capitalize\n\njulia> t = RichText(\"this \", \"is a \", Tag(\"em\", \"very\"), RichText(\" rich\", \" text\"));\n\njulia> render_as(t,\"LaTex\")\n\"this is a \\\\emph{very} rich text\"\n\njulia> convert(String,t)\n\"this is a very rich text\"\n\njulia> t = add_period(capitalize(t));\n\njulia> render_as(t,\"latex\")\n\"This is a \\\\emph{very} rich text.\""
},

{
    "location": "richtextelements.html#Types-1",
    "page": "Rich Text Elements",
    "title": "Types",
    "category": "section",
    "text": "Modules = [BibTeXFormat.RichTextElements]\nOrder   = [:type]"
},

{
    "location": "richtextelements.html#Functions-1",
    "page": "Rich Text Elements",
    "title": "Functions",
    "category": "section",
    "text": "Modules = [BibTeXFormat.RichTextElements]\nOrder   = [:function]"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.Tag",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.Tag",
    "category": "Type",
    "text": "A Tag represents something like an HTML tag or a LaTeX formatting command:\n\njulia> import BibTeXFormat: render_as\n\njulia> tag = Tag(\"em\", \"The TeXbook\");\n\njulia> render_as(tag, \"latex\")\n\"\\\\emph{The TeXbook}\"\n\njulia> render_as(tag, \"html\")\n\"<em>The TeXbook</em>\"\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.capitalize-Tuple{BibTeXFormat.RichTextElements.BaseText}",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.capitalize",
    "category": "Method",
    "text": "function capitalize(self::BaseText)\n\nCapitalize the first letter of the text and lowercasecase the rest.\n\njulia> capitalize(RichText(Tag(\"em\", \"LONG CAT\")))\nRichText(Tag(\"em\", \"Long cat\"))\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.HRef",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.HRef",
    "category": "Type",
    "text": "A HRef represends a hyperlink:\n\njulia> import BibTeXFormat: render_as\n\njulia> href = HRef(\"http://ctan.org/\", \"CTAN\");\n\njulia> print(render_as(href,\"html\"))\n<a href=\"http://ctan.org/\">CTAN</a>\n\njulia> print(render_as(href, \"latex\"))\n\\href{http://ctan.org/}{CTAN}\n\njulia> href = HRef(String(\"http://ctan.org/\"), String(\"http://ctan.org/\"));\n\njulia> print(render_as(href,\"latex\"))\n\\url{http://ctan.org/}\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.Protected",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.Protected",
    "category": "Type",
    "text": "A Protected represents a \"protected\" piece of text.\n\nProtected.lowercase, Protected.uppercase, Protected.capitalize, and Protected.capitalize()   are no-ops and just return the Protected struct itself.\nsplit never splits the text. It always returns a  one-element list containing the Protected struct itself.\nIn LaTeX output, Protected is {surrounded by braces}.  HTML  and plain text backends just output the text as-is.\n\njulia> import BibTeXFormat: render_as\n\njulia> import BibTeXFormat.RichTextElements: Protected, RichString\n\njulia> text = Protected(\"The CTAN archive\");\n\njulia> lowercase(text)\nProtected(\"The CTAN archive\")\n\njulia> print(split(text))\nBibTeXFormat.RichTextElements.Protected[Protected(\"The CTAN archive\")]\n\njulia> print(render_as(text, \"latex\"))\n{The CTAN archive}\n\njulia> print(render_as(text,\"html\"))\n<span class=\"bibtex-protected\">The CTAN archive</span>\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.RichString",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.RichString",
    "category": "Type",
    "text": "A RichString is a wrapper for a plain Julia string.\n\njulia> print(render_as(RichString(\"Crime & Punishment\"),\"text\"))\nCrime & Punishment\njulia> print(render_as(RichString(\"Crime & Punishment\"),\"html\"))\nCrime &amp; Punishment\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.RichString-Tuple",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.RichString",
    "category": "Method",
    "text": "All arguments must be plain unicode strings. Arguments are concatenated together.\n\njulia> print(convert(String,RichString(\"November\", \", \", \"December\", \".\")))\nNovember, December.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.:+-Tuple{BibTeXFormat.RichTextElements.BaseText,Any}",
    "page": "Rich Text Elements",
    "title": "Base.:+",
    "category": "Method",
    "text": "function +(b::BaseText, other)\n\nConcatenate this Text with another Text or string.\n\njulia> a = RichText(\"Longcat is \") + Tag(\"em\", \"long\")\nRichText(\"Longcat is \", Tag(\"em\", \"long\"))\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.:==-Tuple{BibTeXFormat.RichTextElements.RichString,BibTeXFormat.RichTextElements.RichString}",
    "page": "Rich Text Elements",
    "title": "Base.:==",
    "category": "Method",
    "text": "Compare two RichString objects.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.UTF8proc.isalpha-Tuple{BibTeXFormat.RichTextElements.RichString}",
    "page": "Rich Text Elements",
    "title": "Base.UTF8proc.isalpha",
    "category": "Method",
    "text": "Return True if all characters in the string are alphabetic and there is at least one character, False otherwise.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.UTF8proc.isalpha-Tuple{BibTeXFormat.RichTextElements.TextSymbol}",
    "page": "Rich Text Elements",
    "title": "Base.UTF8proc.isalpha",
    "category": "Method",
    "text": "function isalpha(self::TextSymbol)\n\nA TextSymbol is not alfanumeric. Returns false\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.UTF8proc.isalpha-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.UTF8proc.isalpha",
    "category": "Method",
    "text": "function isalpha(self::T) where T<:MultiPartText\n\nReturn true if all characters in the string are alphabetic and there is at least one character, False otherwise.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.contains-Union{Tuple{T,String}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.contains",
    "category": "Method",
    "text": "value in text returns True if any part of the text contains the substring value:\n\njulia> contains(RichText(\"Long cat!\"),\"Long cat\")\ntrue\n\nSubstrings splitted across multiple text parts are not matched:\n\njulia> contains(RichText(Tag(\"em\", \"Long\"), \"cat!\"),\"Long cat\")\nfalse\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.endswith-Tuple{BibTeXFormat.RichTextElements.RichString,Any}",
    "page": "Rich Text Elements",
    "title": "Base.endswith",
    "category": "Method",
    "text": "function endswith(self::RichString, suffix)\n\nReturn True if the string ends with the specified suffix, otherwise return False.\n\nsuffix can also be a tuple of suffixes to look for. return value.endswith(self.value text)\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.endswith-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.endswith",
    "category": "Method",
    "text": "Return True if the text ends with the given suffix.\n\njulia> endswith(RichText(\"Longcat!\"),\"cat!\")\ntrue\n\n\nSuffixes split across multiple parts are not matched:\n\njulia> endswith(RichText(\"Long\", Tag(\"em\", \"cat\"), \"!\"),\"cat!\")\nfalse\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.getindex-Union{Tuple{T,Integer}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.getindex",
    "category": "Method",
    "text": "Slicing and extracting characters works like with regular strings, formatting is preserved.\n\njulia> RichText(\"Longcat is \", Tag(\"em\", \"looooooong!\"))[1:15]\nRichText(\"Longcat is \", Tag(\"em\", \"looo\"))\n\njulia> RichText(\"Longcat is \", Tag(\"em\", \"looooooong!\"))[end]\nRichText(Tag(\"em\", \"!\"))\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.join-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.BaseText",
    "page": "Rich Text Elements",
    "title": "Base.join",
    "category": "Method",
    "text": "function join(self::T, parts) where T<:BaseText\n\nJoin a list using this text (like join)\n\njulia> letters = [\"a\", \"b\", \"c\"];\n\njulia> print(convert(String,join(RichString(\"-\"),letters)))\na-b-c\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.length-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.length",
    "category": "Method",
    "text": "lenght(text) returns the number of characters in the text, ignoring the markup:\n\njulia> length(RichText(\"Long cat\"))\n8\njulia> length(RichText(Tag(\"em\", \"Long\"), \" cat\"))\n8\njulia> length(RichText(HRef(\"http://example.com/\", \"Long\"), \" cat\"))\n8\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.lowercase-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.lowercase",
    "category": "Method",
    "text": "function lowercase(self::T) where T <:MultiPartText\n\nConvert rich text to lowercasecase.\n\njulia> lowercase(RichText(Tag(\"em\", \"Long cat\")))\nRichText(Tag(\"em\", \"long cat\"))\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.split",
    "page": "Rich Text Elements",
    "title": "Base.split",
    "category": "Function",
    "text": "function split(self::RichString, sep=nothing; keep_empty_parts=nothing)\n\nSplit\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.split-Union{Tuple{T,Any}, Tuple{T}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.split",
    "category": "Method",
    "text": "function split(self::T, sep=nothing; keep_empty_parts=nothing) where T <:MultiPartText\n\njulia> print(split(RichText(\"a + b\")))\nAny[RichText(\"a\"), RichText(\"+\"), RichText(\"b\")]\njulia> print(split(RichText(\"a, b\"), \", \"))\nAny[RichText(\"a\"), RichText(\"b\")]\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.startswith-Tuple{BibTeXFormat.RichTextElements.RichString,Any}",
    "page": "Rich Text Elements",
    "title": "Base.startswith",
    "category": "Method",
    "text": "function startswith(self::RichString, prefix)\n\nReturn True if string starts with the prefix, otherwise return False.\n\nprefix can also be a tuple of suffixes to look for.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.startswith-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.startswith",
    "category": "Method",
    "text": "function startswith(self::T, prefix) where T<:MultiPartText\n\nReturn True if the text starts with the given prefix.\n\njulia> startswith(RichText(\"Longcat!\"),\"Longcat\")\ntrue\n\nPrefixes split across multiple parts are not matched:\n\njulia> startswith(RichText(Tag(\"em\", \"Long\"), \"cat!\"),\"Longcat\")\nfalse\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.uppercase-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.uppercase",
    "category": "Method",
    "text": "Convert rich text to uppsercase.\n\njulia> uppercase(RichText(Tag(\"em\", \"Long cat\")))\nRichText(Tag(\"em\", \"LONG CAT\"))\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.add_period",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.add_period",
    "category": "Function",
    "text": "function add_period(self::BaseText, period=\".\")\n\nAdd a period to the end of text, if the last character is not \".\", \"!\" or \"?\".\n\njulia> text = RichText(\"That's all, folks\");\n\njulia> print(convert(String,add_period(text)))\nThat's all, folks.\n\njulia> text = RichText(\"That's all, folks!\");\n\njulia> print(convert(String,add_period(text)))\nThat's all, folks!\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.append-Tuple{BibTeXFormat.RichTextElements.BaseText,Any}",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.append",
    "category": "Method",
    "text": "function append(self::BaseText, text)\n\nAppend text to the end of this text.\n\nNormally, this is the same as concatenating texts with +, but for tags and similar objects the appended text is placed _inside_ the tag.\n\njulia> text = Tag(\"em\", \"Look here\");\n\njulia> print(render_as(text + \"!\",\"html\"))\n<em>Look here</em>!\n\njulia> print(render_as(append(text,\"!\"),\"html\"))\n<em>Look here!</em>\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.append-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.append",
    "category": "Method",
    "text": "function  append(self::T, text) where T<:MultiPartText\n\nAppend text to the end of this text.\n\nFor Tags, HRefs, etc. the appended text is placed inside the tag.\n\njulia> using  BibTeXFormat\n\njulia> text = Tag(\"strong\", \"Chuck Norris\");\n\njulia> print(render_as(text +  \" wins!\",\"html\"))\n<strong>Chuck Norris</strong> wins!\njulia> print(render_as(append(text,\" wins!\"),\"html\"))\n<strong>Chuck Norris wins!</strong>\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.capfirst-Tuple{BibTeXFormat.RichTextElements.BaseText}",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.capfirst",
    "category": "Method",
    "text": "function capfirst(self::BaseText)\n\nCapitalize the first letter of the text.\n\njulia> capfirst(RichText(Tag(\"em\", \"long Cat\")))\nRichText(Tag(\"em\", \"Long Cat\"))\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.create_similar-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.create_similar",
    "category": "Method",
    "text": "function create_similar(self::T, parts) where T<:MultiPartText\n\nCreate a new text object of the same type with the same parameters, with different text content.\n\njulia> text = Tag(\"strong\", \"Bananas!\");\n\njulia> create_similar(text,[\"Apples!\"])\nTag(\"strong\", \"Apples!\")\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.initialize_parts-Tuple",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.initialize_parts",
    "category": "Method",
    "text": "Initialize the parts. A MutliPartText elements must have the following members\n\ntype atype <: MultiPartText\n	parts\n	length\n	info\nend\n\nEmpty parts are ignored:\n\njulia> RichText() == RichText(\"\") == RichText(\"\", \"\", \"\")\ntrue\njulia> RichText(\"Word\", \"\") == RichText(\"Word\")\ntrue\n\nText() objects are unpacked and their children are included directly:\n\njulia> RichText(RichText(\"Multi\", \" \"), Tag(\"em\", \"part\"), RichText(\" \", RichText(\"text!\")))\nRichText(\"Multi \", Tag(\"em\", \"part\"), \" text!\")\n\njulia> Tag(\"strong\", RichText(\"Multi\", \" \"), Tag(\"em\", \"part\"), RichText(\" \", \"text!\"))\nTag(\"strong\", \"Multi \", Tag(\"em\", \"part\"), \" text!\")\n\n\nSimilar objects are merged together:\n\njulia> RichText(\"Multi\", Tag(\"em\", \"part\"), RichText(Tag(\"em\", \" \", \"text!\")))\nRichText(\"Multi\", Tag(\"em\", \"part text!\"))\n\njulia> RichText(\"Please \", HRef(\"/\", \"click\"), HRef(\"/\", \" here\"), \".\")\nRichText(\"Please \", HRef(\"/\", \"click here\"), \".\")\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.merge_similar-Tuple{Any}",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.merge_similar",
    "category": "Method",
    "text": "function merge_similar(param_parts)\n\nMerge adjacent text objects with the same type and parameters together.\n\njulia> parts = [Tag(\"em\", \"Breaking\"), Tag(\"em\", \" \"), Tag(\"em\", \"news!\")];\n\njulia> print(merge_similar(parts))\nAny[Tag(\"em\", \"Breaking news!\")]\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.slice_beginning-Union{Tuple{T,Integer}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.slice_beginning",
    "category": "Method",
    "text": "Return a text consistng of the first slice_length characters of this text (with formatting preserved).\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.slice_end-Union{Tuple{T,Integer}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.slice_end",
    "category": "Method",
    "text": "function slice_end(self::T, slice_length::Integer) where T<:MultiPartText\n\nReturn a text consistng of the last slice_length characters of this text (with formatting preserved).\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichTextElements.typeinfo-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.RichTextElements.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichTextElements.typeinfo",
    "category": "Method",
    "text": "function  typeinfo(self::T) where T<:MultiPartText\n\nReturn the type and the parameters used to create this text object.\n\njulia> using BibTeXFormat\n\njulia> import BibTeXFormat.RichTextElements: Tag, typeinfo\n\njulia> text = Tag(\"strong\", \"Heavy rain!\");\n\njulia> typeinfo(text) == (\"BibTeXFormat.RichTextElements.Tag\", BibTeXFormat.RichTextElements.Tag, \"strong\")\ntrue\n\n\n\n"
},

{
    "location": "richtextelements.html#Reference-1",
    "page": "Rich Text Elements",
    "title": "Reference",
    "category": "section",
    "text": "Modules = [BibTeXFormat.RichTextElements]\nPages   = [\"richtextelements.jl\"]"
},

{
    "location": "templateengine.html#",
    "page": "Template Engine",
    "title": "Template Engine",
    "category": "page",
    "text": ""
},

{
    "location": "templateengine.html#BibTeXFormat.TemplateEngine.format-Tuple{BibTeXFormat.TemplateEngine.Node}",
    "page": "Template Engine",
    "title": "BibTeXFormat.TemplateEngine.format",
    "category": "Method",
    "text": "A convenience function to be used instead of format_data when no data is needed.\n\n\n\n"
},

{
    "location": "templateengine.html#BibTeXFormat.TemplateEngine.format_data-Tuple{BibTeXFormat.TemplateEngine.Node,Any}",
    "page": "Template Engine",
    "title": "BibTeXFormat.TemplateEngine.format_data",
    "category": "Method",
    "text": "Format the given data into a piece of richtext.Text\n\n\n\n"
},

{
    "location": "templateengine.html#Template-Engine-1",
    "page": "Template Engine",
    "title": "Template Engine",
    "category": "section",
    "text": "Pages    = [\"style/templateengine.jl\"]Modules = [BibTeXFormat.TemplateEngine]\nPages    = [\"style/templateengine.jl\"]"
},

{
    "location": "utils.html#",
    "page": "Utilities",
    "title": "Utilities",
    "category": "page",
    "text": ""
},

{
    "location": "utils.html#Utilities-1",
    "page": "Utilities",
    "title": "Utilities",
    "category": "section",
    "text": ""
},

{
    "location": "utils.html#Types-1",
    "page": "Utilities",
    "title": "Types",
    "category": "section",
    "text": "Pages   = [\"utils.md\"]"
},

{
    "location": "utils.html#BibTeXFormat.BibTeXString",
    "page": "Utilities",
    "title": "BibTeXFormat.BibTeXString",
    "category": "Type",
    "text": "julia> import BibTeXFormat: BibTeXString\n\njulia> a = BibTeXString(\"{aaaa{bbbb{cccc{dddd}}}ffff}\");\n\njulia> convert(String,a ) == \"{aaaa{bbbb{cccc{dddd}}}ffff}\"\ntrue\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.abbreviate",
    "page": "Utilities",
    "title": "BibTeXFormat.abbreviate",
    "category": "Function",
    "text": "Abbreviate the given text.\n\njulia> import BibTeXFormat.abbreviate\n\njulia> abbreviate(\"Name\")\n\"N.\"\n\njulia> abbreviate(\"Some words\")\n\"S. w.\"\n\njulia> abbreviate(\"First-Second\")\n\"F.-S.\"\n\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.bibtex_abbreviate",
    "page": "Utilities",
    "title": "BibTeXFormat.bibtex_abbreviate",
    "category": "Function",
    "text": "function bibtex_abbreviate(string, delimiter=None, separator='-')\n\nAbbreviate string.\n\njulia> import BibTeXFormat: bibtex_abbreviate\n\njulia> print(bibtex_abbreviate(\"Andrew Blake\"))\nA\njulia> print(bibtex_abbreviate(\"Jean-Pierre\"))\nJ.-P\njulia> print(bibtex_abbreviate(\"Jean--Pierre\"))\nJ.-P\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.bibtex_first_letter-Tuple{Any}",
    "page": "Utilities",
    "title": "BibTeXFormat.bibtex_first_letter",
    "category": "Method",
    "text": "function  bibtex_first_letter(string)\n\nReturn the first letter or special character of the string.\n\njulia> import BibTeXFormat: bibtex_first_letter\n\njulia> print(bibtex_first_letter(\"Andrew Blake\"))\nA\njulia> print(bibtex_first_letter(\"{Andrew} Blake\"))\nA\njulia> print(bibtex_first_letter(\"1Andrew\"))\nA\njulia> print(bibtex_first_letter(\"{\\\\TeX} markup\"))\n{\\TeX}\njulia> print(bibtex_first_letter(\"\"))\n\njulia> print(bibtex_first_letter(\"123 123 123 {}\"))\n\njulia> print(bibtex_first_letter(\"\\\\LaTeX Project Team\"))\nL\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.bibtex_len-Tuple{Any}",
    "page": "Utilities",
    "title": "BibTeXFormat.bibtex_len",
    "category": "Method",
    "text": "Return the number of characters in the string.\n\nfunction bibtex_len(string)\n\nBraces are ignored. \"Special characters\" are ignored. A \"special character\" is a substring at brace level 1, if the first character after the opening brace is a backslash, like in \"de la Vall{\\'e}e Poussin\".\n\njulia> import BibTeXFormat: bibtex_len\n\njulia> print(bibtex_len(\"de la Vall{\\\\'e}e Poussin\"))\n20\njulia> print(bibtex_len(\"de la Vall{e}e Poussin\"))\n20\njulia> print(bibtex_len(\"de la Vallee Poussin\"))\n20\njulia> print(bibtex_len(\"\\\\ABC 123\"))\n8\njulia> print(bibtex_len(\"{\\\\abc}\"))\n1\njulia> print(bibtex_len(\"{\\\\abc\"))\n1\njulia> print(bibtex_len(\"}\\\\abc\"))\n4\njulia> print(bibtex_len(\"\\\\abc}\"))\n4\njulia> print(bibtex_len(\"\\\\abc{\"))\n4\njulia> print(bibtex_len(\"level 0 {1 {2}}\"))\n11\njulia> print(bibtex_len(\"level 0 {\\\\1 {2}}\"))\n9\njulia> print(bibtex_len(\"level 0 {1 {\\\\2}}\"))\n12\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.bibtex_purify-Tuple{Any}",
    "page": "Utilities",
    "title": "BibTeXFormat.bibtex_purify",
    "category": "Method",
    "text": "function bibtex_purify(str)\n\nStrip special characters from the string.\n\njulia> import BibTeXFormat: bibtex_purify\n\njulia> print(bibtex_purify(\"Abc 1234\"))\nAbc 1234\njulia> print(bibtex_purify(\"Abc  1234\"))\nAbc  1234\njulia> print(bibtex_purify(\"Abc-Def\"))\nAbc Def\njulia> print(bibtex_purify(\"Abc-~-Def\"))\nAbc   Def\njulia> print(bibtex_purify(\"{XXX YYY}\"))\nXXX YYY\njulia> print(bibtex_purify(\"{XXX {YYY}}\"))\nXXX YYY\njulia> print(bibtex_purify(\"XXX {\\\\YYY} XXX\"))\nXXX  XXX\njulia> print(bibtex_purify(\"{XXX {\\\\YYY} XXX}\"))\nXXX YYY XXX\njulia> print(bibtex_purify(\"\\\\abc def\"))\nabc def\njulia> print(bibtex_purify(\"a@#\\$@#\\$b@#\\$@#\\$c\"))\nabc\njulia> print(bibtex_purify(\"{\\\\noopsort{1973b}}1973\"))\n1973b1973\njulia> print(bibtex_purify(\"{sort{1973b}}1973\"))\nsort1973b1973\njulia> print(bibtex_purify(\"{sort{\\\\abc1973b}}1973\"))\nsortabc1973b1973\njulia> print(bibtex_purify(\"{\\\\noopsort{1973a}}{\\\\switchargs{--90}{1968}}\"))\n1973a901968\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.bibtex_substring-Tuple{Any,Any,Any}",
    "page": "Utilities",
    "title": "BibTeXFormat.bibtex_substring",
    "category": "Method",
    "text": "function bibtex_substring(string, start, length)\n\nReturn a substring of the given length, starting from the given position.\n\nstart and length are 1-based. If start is < 0, it is counted from the end of the string. If start is 0, an empty string is returned.\n\njulia> import BibTeXFormat: bibtex_substring\n\njulia> print(bibtex_substring(\"abcdef\", 1, 3))\nabc\njulia> print(bibtex_substring(\"abcdef\", 2, 3))\nbcd\njulia> print(bibtex_substring(\"abcdef\", 2, 1000))\nbcdef\njulia> print(bibtex_substring(\"abcdef\", 0, 1000))\n\njulia> print(bibtex_substring(\"abcdef\", -1, 1))\nf\njulia> print(bibtex_substring(\"abcdef\", -1, 2))\nef\njulia> print(bibtex_substring(\"abcdef\", -2, 3))\ncde\njulia> print(bibtex_substring(\"abcdef\", -2, 1000))\nabcde\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.change_case-Tuple{String,Char}",
    "page": "Utilities",
    "title": "BibTeXFormat.change_case",
    "category": "Method",
    "text": "function change_case(string, mode)\n\njulia> import BibTeXFormat: change_case\n\njulia> print(change_case(\"aBcD\", 'l'))\nabcd\njulia> print(change_case(\"aBcD\", 'u'))\nABCD\njulia> print(change_case(\"ABcD\", 't'))\nAbcd\njulia> change_case(\"The {\\\\TeX book \\\\noop}\", 'u')\n\"THE {\\\\TeX BOOK \\\\noop}\"\n\njulia> change_case(\"And Now: BOOO!!!\", 't')\n\"And now: Booo!!!\"\n\njulia> change_case(\"And {Now: BOOO!!!}\", 't')\n\"And {Now: BOOO!!!}\"\n\njulia> change_case(\"And {Now: {BOOO}!!!}\", 'l')\n\"and {Now: {BOOO}!!!}\"\n\njulia> change_case(\"And {\\\\Now: BOOO!!!}\", 't')\n\"And {\\\\Now: booo!!!}\"\n\njulia> change_case(\"And {\\\\Now: {BOOO}!!!}\", 'l')\n\"and {\\\\Now: {booo}!!!}\"\n\njulia> change_case(\"{\\\\TeX\\\\ and databases\\\\Dash\\\\TeX DBI}\", 't')\n\"{\\\\TeX\\\\ and databases\\\\Dash\\\\TeX DBI}\"\n\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.scan_bibtex_string-Tuple{Any}",
    "page": "Utilities",
    "title": "BibTeXFormat.scan_bibtex_string",
    "category": "Method",
    "text": "Yield (char, brace_level) tuples.\n\n\"Special characters\", as in bibtex_len, are treated as a single character\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.split_keep_separator",
    "page": "Utilities",
    "title": "BibTeXFormat.split_keep_separator",
    "category": "Function",
    "text": "Split a text keep the separators\n\njulia> import BibTeXFormat.split_keep_separator\n\njulia> split_keep_separator(\"Some words-words\")\n5-element Array{Any,1}:\n \"Some\"\n ' '\n \"words\"\n '-'\n \"words\"\n\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.split_name_list-Tuple{Any}",
    "page": "Utilities",
    "title": "BibTeXFormat.split_name_list",
    "category": "Method",
    "text": "Split a list of names, separated by ' and '.\n\njulia> import BibTeXFormat.split_name_list\n\njulia> split_name_list(\"Johnson and Peterson\")\n2-element Array{String,1}:\n \"Johnson\"\n \"Peterson\"\n\njulia> split_name_list(\"Johnson AND Peterson\")\n2-element Array{String,1}:\n \"Johnson\"\n \"Peterson\"\n\njulia> split_name_list(\"Johnson AnD Peterson\")\n2-element Array{String,1}:\n \"Johnson\"\n \"Peterson\"\n\njulia> split_name_list(\"Armand and Peterson\")\n2-element Array{String,1}:\n \"Armand\"\n \"Peterson\"\n\njulia> split_name_list(\"Armand and anderssen\")\n2-element Array{String,1}:\n \"Armand\"\n \"anderssen\"\n\njulia> split_name_list(\"{Armand and Anderssen}\")\n1-element Array{String,1}:\n \"{Armand and Anderssen}\"\n\njulia> split_name_list(\"What a Strange{ }and Bizzare Name! and Peterson\")\n2-element Array{String,1}:\n \"What a Strange{ }and Bizzare Name!\"\n \"Peterson\"\n\njulia> split_name_list(\"What a Strange and{ }Bizzare Name! and Peterson\")\n2-element Array{String,1}:\n \"What a Strange and{ }Bizzare Name!\"\n \"Peterson\"\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.split_tex_string",
    "page": "Utilities",
    "title": "BibTeXFormat.split_tex_string",
    "category": "Function",
    "text": "Split a string using the given separator (regexp).\n\nEverything at brace level > 0 is ignored. Separators at the edges of the string are ignored.\n\njulia> import BibTeXFormat.split_tex_string\n\njulia> split_tex_string(\"\")\n0-element Array{Any,1}\n\njulia> split_tex_string(\"     \")\n0-element Array{String,1}\n\njulia> split_tex_string(\"   \", \" \", strip=false, filter_empty=false)\n2-element Array{Any,1}:\n \" \"\n \" \"\n\njulia> split_tex_string(\".a.b.c.\", r\"\\.\")\n3-element Array{String,1}:\n \".a\"\n \"b\"\n \"c.\"\n\njulia> split_tex_string(\".a.b.c.{d.}.\", r\"\\.\")\n4-element Array{String,1}:\n \".a\"\n \"b\"\n \"c\"\n \"{d.}.\"\n\njulia> split_tex_string(\"Matsui      Fuuka\")\n2-element Array{String,1}:\n \"Matsui\"\n \"Fuuka\"\n\njulia> split_tex_string(\"{Matsui      Fuuka}\")\n1-element Array{String,1}:\n \"{Matsui      Fuuka}\"\n\njulia> split_tex_string(r\"Matsui Fuuka\")\n2-element Array{String,1}:\n \"Matsui\"\n \"Fuuka\"\n\njulia> split_tex_string(\"{Matsui Fuuka}\")\n1-element Array{String,1}:\n \"{Matsui Fuuka}\"\n\njulia> split_tex_string(\"a\")\n1-element Array{String,1}:\n \"a\"\n\njulia> split_tex_string(\"on a\")\n2-element Array{String,1}:\n \"on\"\n \"a\"\n\n\n\n\n"
},

{
    "location": "utils.html#BibTeXFormat.latex_parse-Tuple{Any}",
    "page": "Utilities",
    "title": "BibTeXFormat.latex_parse",
    "category": "Method",
    "text": "from nose.tools import assert_raises\n\nLaTeXParser('abc').parse()\n\nText('abc')\n\nLaTeXParser('abc{def}').parse()\n\nText('abc', Protected('def'))\n\nLaTeXParser('abc{def {xyz}} !').parse()\n\nText('abc', Protected('def ', Protected('xyz')), ' !')\n\nassert_raises(PybtexSyntaxError, LaTeXParser('abc{def}}').parse) assert_raises(PybtexSyntaxError, LaTeXParser('abc{def}{').parse)\n\n\n\n"
},

{
    "location": "utils.html#Reference-1",
    "page": "Utilities",
    "title": "Reference",
    "category": "section",
    "text": "Modules = [BibTeXFormat]\nPages   = [\"utils.jl\", \"latexparser.jl\"]"
},

]}
