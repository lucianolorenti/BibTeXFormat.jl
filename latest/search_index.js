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
    "location": "style.html#",
    "page": "Style",
    "title": "Style",
    "category": "page",
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
    "location": "style.html#BibTeXFormat.expand_wildcard_citations-Tuple{BibTeX.Bibliography,Any}",
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
    "text": "function format_bibliography(self::T, bib_data, citations=nothing) where T<:BaseStyle\n\nFormat bibliography entries with the given keys and return a FormattedBibliography object.\n\nParams:\n\nself::T where T<:BaseStyle. The style\nbib_data A :py:class:pybtex.database.BibliographyData object.\nparam citations: A list of citation keys.\n\nusing BibTeX\nusing BibTeXFormat\nbibliography      = Bibliography(readstring(\"test/Clustering.bib\"))\n\nformatted_entries = format_entries(AlphaStyle,bibliography)\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.format_entry-Union{Tuple{T,Any,Any}, Tuple{T}} where T<:BibTeXFormat.BaseStyle",
    "page": "Style",
    "title": "BibTeXFormat.format_entry",
    "category": "Method",
    "text": "function format_entry(b::T, label, entry) where T <: BaseStyle\n\nFormat an entry with a given style b::T where T <: BaseStyle\n\n\n\n"
},

{
    "location": "style.html#BibTeXFormat.get_crossreferenced_citations-Tuple{BibTeX.Bibliography,Any}",
    "page": "Style",
    "title": "BibTeXFormat.get_crossreferenced_citations",
    "category": "Method",
    "text": "Get cititations not cited explicitly but referenced by other citations.\n\njulia> using BibTeX\n\njulia> import BibTeXFormat: get_crossreferenced_citations\n\njulia> data = Bibliography(\"\", Dict{String,Citation}(\"main_article\"=>Citation{:article}(Dict(\"crossref\"=>\"xrefd_article\")),\"xrefd_article\"=>Citation{:article}()));\n\njulia> print(get_crossreferenced_citations(data, [], min_crossrefs=1))\nAny[]\njulia> print(get_crossreferenced_citations(data, [\"main_article\"], min_crossrefs=1))\nAny[\"xrefd_article\"]\njulia> print(get_crossreferenced_citations(data,[\"Main_article\"], min_crossrefs=1))\nAny[\"xrefd_article\"]\njulia> print(get_crossreferenced_citations(data, [\"main_article\"], min_crossrefs=2))\nAny[]\njulia> print(get_crossreferenced_citations(data, [\"xrefd_arcicle\"], min_crossrefs=1))\nWARNING: bad cross-reference: entry \"xrefd_arcicle\" refers to\n                entry \"nothing\" which does not exist.\nAny[]\n\n\n\n"
},

{
    "location": "style.html#Style-1",
    "page": "Style",
    "title": "Style",
    "category": "section",
    "text": "Pages    = [\"style.jl\"]Modules = [BibTeXFormat]\nPages    = [\"style.jl\"]"
},

{
    "location": "backends.html#",
    "page": "Backends",
    "title": "Backends",
    "category": "page",
    "text": ""
},

{
    "location": "backends.html#Backends-1",
    "page": "Backends",
    "title": "Backends",
    "category": "section",
    "text": ""
},

{
    "location": "backends.html#BibTeXFormat.HTMLBackend",
    "page": "Backends",
    "title": "BibTeXFormat.HTMLBackend",
    "category": "Type",
    "text": "from pybtex.richtext import Text, Tag, Symbol print(Tag('em', Text(u'Ð›.:', Symbol('nbsp'), u'<<Ð¥Ð¸Ð¼Ð¸Ñ>>')).render(HTMLBackend()))\n\n<em>Ð›.:&nbsp;&lt;&lt;Ð¥Ð¸Ð¼Ð¸Ñ&gt;&gt;</em>\n\n\n\n"
},

{
    "location": "backends.html#HTML-1",
    "page": "Backends",
    "title": "HTML",
    "category": "section",
    "text": "Pages    = [\"backends/html.jl\"]Modules = [BibTeXFormat]\nPages    = [\"backends/html.jl\"]"
},

{
    "location": "backends.html#BibTeXFormat.format-Tuple{BibTeXFormat.LaTeXBackend,BibTeXFormat.Protected,Any}",
    "page": "Backends",
    "title": "BibTeXFormat.format",
    "category": "Method",
    "text": "from pybtex.richtext import Protected print(Protected(\"CTAN\").render_as(\"latex\"))\n\n{CTAN}\n\n\n\n"
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
    "text": "DocTestSetup = quote\nusing BibTeXFormat\nimport BibTeXFormat: RichText, Tag, append, render_as, add_period, capfirst,\n                    capitalize, typeinfo, create_similar, HRef,\n                    merge_similar, render_as, Protected,\n                    RichString\nend"
},

{
    "location": "richtextelements.html#Description-1",
    "page": "Rich Text Elements",
    "title": "Description",
    "category": "section",
    "text": "(simple but) rich text formatting toolsjulia> import BibTeXFormat: RichText, Tag, render_as, add_period, capitalize\n\njulia> t = RichText(\"this \", \"is a \", Tag(\"em\", \"very\"), RichText(\" rich\", \" text\"));\n\njulia> render_as(t,\"LaTex\")\n\"this is a \\\\emph{very} rich text\"\n\njulia> convert(String,t)\n\"this is a very rich text\"\n\njulia> t = add_period(capitalize(t));\n\njulia> render_as(t,\"latex\")\n\"This is a \\\\emph{very} rich text.\""
},

{
    "location": "richtextelements.html#Types-1",
    "page": "Rich Text Elements",
    "title": "Types",
    "category": "section",
    "text": "Pages   = [\"richtextelements.md\"]\nOrder   = [:type]"
},

{
    "location": "richtextelements.html#Functions-1",
    "page": "Rich Text Elements",
    "title": "Functions",
    "category": "section",
    "text": "Pages   = [\"richtextelements.md\"]\nOrder   = [:function]"
},

{
    "location": "richtextelements.html#BibTeXFormat.HRef",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.HRef",
    "category": "Type",
    "text": "A HRef represends a hyperlink:\n\njulia> href = HRef(\"http://ctan.org/\", \"CTAN\");\n\njulia> print(render_as(href,\"html\"))\n<a href=\"http://ctan.org/\">CTAN</a>\n\njulia> print(render_as(href, \"latex\"))\n\\href{http://ctan.org/}{CTAN}\n\njulia> href = HRef(String(\"http://ctan.org/\"), String(\"http://ctan.org/\"));\n\njulia> print(render_as(href,\"latex\"))\n\\url{http://ctan.org/}\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.Protected",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.Protected",
    "category": "Type",
    "text": "A Protected represents a \"protected\" piece of text.\n\nProtected.lowercase, Protected.uppercase, Protected.capitalize, and Protected.capitalize()   are no-ops and just return the Protected struct itself.\nsplit never splits the text. It always returns a  one-element list containing the Protected struct itself.\nIn LaTeX output, Protected is {surrounded by braces}.  HTML  and plain text backends just output the text as-is.\n\n´´´jldoctest julia> text = Protected(\"The CTAN archive\"); julia> lowercase(text) BibTeXFormat.Protected(Any[BibTeXFormat.RichString(\"The CTAN archive\")], 16, \"\")\n\njulia> print(split(text)) BibTeXFormat.Protected[BibTeXFormat.Protected(Any[BibTeXFormat.RichString(\"The CTAN archive\")], 16, \"\")]\n\njulia> print(render_as(text, \"latex\")) {The CTAN archive}\n\njulia> print(render_as(text,\"html\")) <span class=\"bibtex-protected\">The CTAN archive</span>\n\n´´´\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichString",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichString",
    "category": "Type",
    "text": "A RichString is a wrapper for a plain Julia string.\n\njulia> print(render_as(RichString(\"Crime & Punishment\"),\"text\"))\nCrime & Punishment\njulia> print(render_as(RichString(\"Crime & Punishment\"),\"html\"))\nCrime &amp; Punishment\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.RichString-Tuple",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.RichString",
    "category": "Method",
    "text": "All arguments must be plain unicode strings. Arguments are concatenated together.\n\njulia> print(convert(String,RichString(\"November\", \", \", \"December\", \".\")))\nNovember, December.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.:+-Tuple{BibTeXFormat.BaseText,Any}",
    "page": "Rich Text Elements",
    "title": "Base.:+",
    "category": "Method",
    "text": "function +(b::BaseText, other)\n\nConcatenate this Text with another Text or string.\n\njulia> a = RichText(\"Longcat is \") + Tag(\"em\", \"long\")\nRichText(\"Longcat is \", Tag(\"em\", \"long\"))\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.:==-Tuple{BibTeXFormat.RichString,BibTeXFormat.RichString}",
    "page": "Rich Text Elements",
    "title": "Base.:==",
    "category": "Method",
    "text": "Compare two RichString objects.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.UTF8proc.isalpha-Tuple{BibTeXFormat.RichString}",
    "page": "Rich Text Elements",
    "title": "Base.UTF8proc.isalpha",
    "category": "Method",
    "text": "Return True if all characters in the string are alphabetic and there is at least one character, False otherwise.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.UTF8proc.isalpha-Tuple{BibTeXFormat.TextSymbol}",
    "page": "Rich Text Elements",
    "title": "Base.UTF8proc.isalpha",
    "category": "Method",
    "text": "A TextSymbol is not alfanumeric. Returns false\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.UTF8proc.isalpha-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.UTF8proc.isalpha",
    "category": "Method",
    "text": "Return True if all characters in the string are alphabetic and there is at least one character, False otherwise.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.contains-Union{Tuple{T,String}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.contains",
    "category": "Method",
    "text": "value in text returns True if any part of the text contains the substring value:\n\njulia> contains(RichText(\"Long cat!\"),\"Long cat\")\ntrue\n\nSubstrings splitted across multiple text parts are not matched:\n\njulia> contains(RichText(Tag(\"em\", \"Long\"), \"cat!\"),\"Long cat\")\nfalse\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.endswith-Tuple{BibTeXFormat.RichString,Any}",
    "page": "Rich Text Elements",
    "title": "Base.endswith",
    "category": "Method",
    "text": "Return True if the string ends with the specified suffix, otherwise return False.\n\nsuffix can also be a tuple of suffixes to look for. return self.value.endswith(text)\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.endswith-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.endswith",
    "category": "Method",
    "text": "Return True if the text ends with the given suffix.\n\njulia> endswith(RichText(\"Longcat!\"),\"cat!\")\ntrue\n\n\nSuffixes split across multiple parts are not matched:\n\njulia> endswith(RichText(\"Long\", Tag(\"em\", \"cat\"), \"!\"),\"cat!\")\nfalse\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.getindex-Union{Tuple{T,Integer}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.getindex",
    "category": "Method",
    "text": "Slicing and extracting characters works like with regular strings, formatting is preserved.\n\njulia> RichText(\"Longcat is \", Tag(\"em\", \"looooooong!\"))[1:15]\nRichText(\"Longcat is \", Tag(\"em\", \"looo\"))\n\njulia> RichText(\"Longcat is \", Tag(\"em\", \"looooooong!\"))[end]\nRichText(Tag(\"em\", \"!\"))\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.join-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.BaseText",
    "page": "Rich Text Elements",
    "title": "Base.join",
    "category": "Method",
    "text": "function join(self::T, parts) where T<:BaseText\n\nJoin a list using this text (like join)\n\njulia> letters = [\"a\", \"b\", \"c\"];\n\njulia> print(convert(String,join(RichString(\"-\"),letters)))\na-b-c\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.length-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.length",
    "category": "Method",
    "text": "lenght(text) returns the number of characters in the text, ignoring the markup:\n\njulia> length(RichText(\"Long cat\"))\n8\njulia> length(RichText(Tag(\"em\", \"Long\"), \" cat\"))\n8\njulia> length(RichText(HRef(\"http://example.com/\", \"Long\"), \" cat\"))\n8\n\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.lowercase-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.lowercase",
    "category": "Method",
    "text": "Convert rich text to lowercasecase.\n\njulia> lowercase(RichText(Tag(\"em\", \"Long cat\")))\nRichText(Tag(\"em\", \"long cat\"))\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.split",
    "page": "Rich Text Elements",
    "title": "Base.split",
    "category": "Function",
    "text": "Split\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.split-Union{Tuple{T,Any}, Tuple{T}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.split",
    "category": "Method",
    "text": "julia> print(split(RichText(\"a + b\")))\nAny[RichText(\"a\"), RichText(\"+\"), RichText(\"b\")]\njulia> print(split(RichText(\"a, b\"), \", \"))\nAny[RichText(\"a\"), RichText(\"b\")]\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.startswith-Tuple{BibTeXFormat.RichString,Any}",
    "page": "Rich Text Elements",
    "title": "Base.startswith",
    "category": "Method",
    "text": "Return True if string starts with the prefix, otherwise return False.\n\nprefix can also be a tuple of suffixes to look for.\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.startswith-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.startswith",
    "category": "Method",
    "text": "Return True if the text starts with the given prefix.\n\njulia> startswith(RichText(\"Longcat!\"),\"Longcat\")\ntrue\n\nPrefixes split across multiple parts are not matched:\n\njulia> startswith(RichText(Tag(\"em\", \"Long\"), \"cat!\"),\"Longcat\")\nfalse\n\n\n\n"
},

{
    "location": "richtextelements.html#Base.uppercase-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "Base.uppercase",
    "category": "Method",
    "text": "Convert rich text to uppsercase.\n\njulia> uppercase(RichText(Tag(\"em\", \"Long cat\")))\nRichText(Tag(\"em\", \"LONG CAT\"))\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.add_period",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.add_period",
    "category": "Function",
    "text": "function add_period(self::BaseText, period=\".\")\n\nAdd a period to the end of text, if the last character is not \".\", \"!\" or \"?\".\n\njulia> text = RichText(\"That's all, folks\");\n\njulia> print(convert(String,add_period(text)))\nThat's all, folks.\n\njulia> text = RichText(\"That's all, folks!\");\n\njulia> print(convert(String,add_period(text)))\nThat's all, folks!\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.append-Tuple{BibTeXFormat.BaseText,Any}",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.append",
    "category": "Method",
    "text": "function append(self::BaseText, text)\n\nAppend text to the end of this text.\n\nNormally, this is the same as concatenating texts with +, but for tags and similar objects the appended text is placed _inside_ the tag.\n\njulia> text = Tag(\"em\", \"Look here\");\n\njulia> print(render_as(text + \"!\",\"html\"))\n<em>Look here</em>!\n\njulia> print(render_as(append(text,\"!\"),\"html\"))\n<em>Look here!</em>\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.append-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.append",
    "category": "Method",
    "text": "Append text to the end of this text.\n\nFor Tags, HRefs, etc. the appended text is placed inside the tag.\n\njulia> text = Tag(\"strong\", \"Chuck Norris\");\n\njulia> print(render_as(text +  \" wins!\",\"html\"))\n<strong>Chuck Norris</strong> wins!\njulia> print(render_as(append(text,\" wins!\"),\"html\"))\n<strong>Chuck Norris wins!</strong>\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.capfirst-Tuple{BibTeXFormat.BaseText}",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.capfirst",
    "category": "Method",
    "text": "function capfirst(self::BaseText)\n\nCapitalize the first letter of the text.\n\njulia> capfirst(RichText(Tag(\"em\", \"long Cat\")))\nRichText(Tag(\"em\", \"Long Cat\"))\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.capitalize-Tuple{BibTeXFormat.BaseText}",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.capitalize",
    "category": "Method",
    "text": "function capitalize(self::BaseText)\n\nCapitalize the first letter of the text and lowercasecase the rest.\n\njulia> capitalize(RichText(Tag(\"em\", \"LONG CAT\")))\nRichText(Tag(\"em\", \"Long cat\"))\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.create_similar-Union{Tuple{T,Any}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.create_similar",
    "category": "Method",
    "text": "function create_similar(self::T, parts) where T<:MultiPartText\n\nCreate a new text object of the same type with the same parameters, with different text content.\n\njulia> text = Tag(\"strong\", \"Bananas!\");\n\njulia> create_similar(text,[\"Apples!\"])\nTag(\"strong\", \"Apples!\")\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.initialize_parts-Tuple",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.initialize_parts",
    "category": "Method",
    "text": "Initialize the parts. A MutliPartText elements must have the following members\n\ntype atype <: MultiPartText\n	parts\n	length\n	info\nend\n\nEmpty parts are ignored:\n\njulia> RichText() == RichText(\"\") == RichText(\"\", \"\", \"\")\ntrue\njulia> RichText(\"Word\", \"\") == RichText(\"Word\")\ntrue\n\nText() objects are unpacked and their children are included directly:\n\njulia> RichText(RichText(\"Multi\", \" \"), Tag(\"em\", \"part\"), RichText(\" \", RichText(\"text!\")))\nRichText(\"Multi \", Tag(\"em\", \"part\"), \" text!\")\n\njulia> Tag(\"strong\", RichText(\"Multi\", \" \"), Tag(\"em\", \"part\"), RichText(\" \", \"text!\"))\nTag(\"strong\", \"Multi \", Tag(\"em\", \"part\"), \" text!\")\n\n\nSimilar objects are merged together:\n\njulia> RichText(\"Multi\", Tag(\"em\", \"part\"), RichText(Tag(\"em\", \" \", \"text!\")))\nRichText(\"Multi\", Tag(\"em\", \"part text!\"))\n\njulia> RichText(\"Please \", HRef(\"/\", \"click\"), HRef(\"/\", \" here\"), \".\")\nRichText(\"Please \", HRef(\"/\", \"click here\"), \".\")\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.merge_similar-Tuple{Any}",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.merge_similar",
    "category": "Method",
    "text": "Merge adjacent text objects with the same type and parameters together.\n\njulia> parts = [Tag(\"em\", \"Breaking\"), Tag(\"em\", \" \"), Tag(\"em\", \"news!\")];\n\njulia> print(merge_similar(parts))\nAny[Tag(\"em\", \"Breaking news!\")]\n\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.slice_beginning-Union{Tuple{T,Integer}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.slice_beginning",
    "category": "Method",
    "text": "Return a text consistng of the first slice_length characters of this text (with formatting preserved).\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.slice_end-Union{Tuple{T,Integer}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.slice_end",
    "category": "Method",
    "text": "Return a text consistng of the last slice_length characters of this text (with formatting preserved).\n\n\n\n"
},

{
    "location": "richtextelements.html#BibTeXFormat.typeinfo-Union{Tuple{T}, Tuple{T}} where T<:BibTeXFormat.MultiPartText",
    "page": "Rich Text Elements",
    "title": "BibTeXFormat.typeinfo",
    "category": "Method",
    "text": "function  typeinfo(self::T) where T<:MultiPartText\n\nReturn the type and the parameters used to create this text object.\n\njulia> text = Tag(\"strong\", \"Heavy rain!\");\n\njulia> typeinfo(text) == (\"BibTeXFormat.Tag\", BibTeXFormat.Tag, \"strong\")\ntrue\n\n\n\n"
},

{
    "location": "richtextelements.html#Reference-1",
    "page": "Rich Text Elements",
    "title": "Reference",
    "category": "section",
    "text": "Modules = [BibTeXFormat]\nPages   = [\"richtextelements.jl\"]"
},

{
    "location": "templateengine.html#",
    "page": "Template Engine",
    "title": "Template Engine",
    "category": "page",
    "text": ""
},

{
    "location": "templateengine.html#BibTeXFormat.format-Tuple{BibTeXFormat.Node}",
    "page": "Template Engine",
    "title": "BibTeXFormat.format",
    "category": "Method",
    "text": "A convenience function to be used instead of format_data when no data is needed.\n\n\n\n"
},

{
    "location": "templateengine.html#BibTeXFormat.format_data-Tuple{BibTeXFormat.Node,Any}",
    "page": "Template Engine",
    "title": "BibTeXFormat.format_data",
    "category": "Method",
    "text": "Format the given data into a piece of richtext.Text\n\n\n\n"
},

{
    "location": "templateengine.html#Template-Engine-1",
    "page": "Template Engine",
    "title": "Template Engine",
    "category": "section",
    "text": "Pages    = [\"style/templateengine.jl\"]Modules = [BibTeXFormat]\nPages    = [\"style/templateengine.jl\"]"
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
