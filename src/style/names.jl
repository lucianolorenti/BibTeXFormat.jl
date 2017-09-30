
abstract type BaseNameStyle end
import BibTeXFormat.TemplateEngine: @node
@node function  name_part(children, data; before="", tie=false, abbr=false)

    if abbr
        children = [BibTeXFormat.RichTextElements.abbreviate(child) for child in children]
	end
    parts = format_data(together(;last_tie=true)[children],data)
    if length(parts) == 0
        return RichText("")
	end
    if tie
        return RichText(before, parts, tie_or_space(parts, nbsp, " "))
    else
        return RichText(before, parts)
	end
end

struct LastFirstNameStyle <: BaseNameStyle end
#test in runtest.jl
doc"""
```
function format(self::LastFirstNameStyle, person, abbr=false)
```
Format names similarly to {vv~}{ll}{, jj}{, f.} in BibTeX.

```julia
julia> import BibTeXFormat: Person, render_as, LastFirstNameStyle, format

julia> import BibTeXFormat.TemplateEngine

julia> name = Person("Charles Louis Xavier Joseph de la Vall{\\'e}e Poussin");

julia> lastfirst = LastFirstNameStyle();

julia> render_as(TemplateEngine.format(format(lastfirst,name)),"latex")
"de~la Vall{e\u0301}e~Poussin, Charles Louis Xavier~Joseph"

julia> render_as(TemplateEngine.format(format(lastfirst,name)),"html")
"de&nbsp;la Vall<span class=\"bibtex-protected\">e\u0301</span>e&nbsp;Poussin, Charles Louis Xavier&nbsp;Joseph"

julia> render_as(TemplateEngine.format(format(lastfirst,name, true)),"latex")
"de~la Vall{e\u0301}e~Poussin, C.~L. X.~J."

julia> render_as(TemplateEngine.format(format(lastfirst,name, true)),"html")
"de&nbsp;la Vall<span class=\"bibtex-protected\">e\u0301</span>e&nbsp;Poussin, C.&nbsp;L. X.&nbsp;J."

julia> name = Person(first="First", last="Last", middle="Middle");

julia> render_as(TemplateEngine.format(format(lastfirst,name)),"latex")
"Last, First~Middle"

julia> render_as(TemplateEngine.format(format(lastfirst,name, true)),"latex")
"Last, F.~M."

```
"""
function format(self::LastFirstNameStyle, person, abbr=false)
	return join[
        name_part(tie=true)[rich_prelast_names(person)...],
        name_part[rich_last_names(person)...],
        name_part(before=", ")[rich_lineage_names(person)...],
        name_part(before=", ",abbr=abbr)[rich_first_names(person)...,rich_middle_names(person)...],
	]
end

struct PlainNameStyle <: BaseNameStyle end
#test in runtest.jl
doc"""
Format names similarly to {ff~}{vv~}{ll}{, jj} in BibTeX.

```julia
julia> import BibTeXFormat: Person, render_as, PlainNameStyle, format

julia> import BibTeXFormat.TemplateEngine

julia> name = Person("Charles Louis Xavier Joseph de la Vall{\'e}e Poussin");

julia> plain = PlainNameStyle();

julia> render_as(TemplateEngine.format(format(plain, name)),"latex")
"Charles Louis Xavier~Joseph de~la Vall{e\u0301}e~Poussin"

julia> render_as(TemplatEngine.format(format(plain, name),"html"))
"Charles Louis Xavier&nbsp;Joseph de&nbsp;la Vall<span class=\"bibtex-protected\">e\u0301</span>e&nbsp;Poussin"

julia> render_as(TemplateEngine.format(format(plain,name, true)), "latex")
"C.~L. X.~J. de~la Vall{e\u0301}e~Poussin"

julia> render_as(TemplateEngine.format(format(plain, name, true)),"html")
"C.&nbsp;L. X.&nbsp;J. de&nbsp;la Vall<span class=\"bibtex-protected\">e\u0301</span>e&nbsp;Poussin"

julia> name = Person(first="First", last="Last", middle="Middle");

julia> render_as(TemplateEngine.format(format(plain, name)),"latex")
"First~Middle Last"

julia> render_as(TemplateEngine.format(format(plain,name, true)),"latex")
"F.~M. Last"

julia> render_as(TemplateEngine.format(format(plain,Person("de Last, Jr., First Middle"))),"latex")
"First~Middle de~Last, Jr."

```
"""
function format(self::PlainNameStyle, person, abbr=false)
	return join[
             name_part(tie=true, abbr=abbr)[rich_first_names(person)...,rich_middle_names(person)...],
             name_part(tie=true)[rich_prelast_names(person)...],
             name_part[rich_last_names(person)...],
             name_part(before=", ")[rich_lineage_names(person)...]
	]
end
