using Base.Test

doc"""
LaTeX output backend.
```jldoctest
julia> import BibTeXFormat: LaTeXBackend, render

julia> import BibTeXFormat.RichTextElements: Tag, HRef

julia> latex = LaTeXBackend();

julia> print(render(Tag("em", ""),latex))

julia> print(render(Tag("em", "Non-", "empty"),latex))
\emph{Non-empty}
julia> print(render(HRef("/", ""),latex))

julia> print(render(HRef("/", "Non-", "empty"),latex))
\href{/}{Non-empty}
julia> print(render(HRef("http://example.org/", "http://example.org/"),latex))
\url{http://example.org/}
```
"""
struct LaTeXBackend <: BaseBackend
	enconding::String
	latex_enconding::String
    preamble::String
end

default_suffix[LaTeXBackend] = ".bbl"
symbols[LaTeXBackend]        = Dict{String,String}(
        "ndash"=> "--",
        "newblock"=> "\n\\newblock ",
        "nbsp"=> "~"
  )
tags[LaTeXBackend] = Dict{String,String}(
        "em"=> "emph",
        "strong"=>"",
        "i"=> "textit",
        "b"=> "textbf",
        "tt"=> "texttt"
)
function LaTeXBackend(enconding=nothing)
	local eenconding = "UTF-8"
	return LaTeXBackend(eenconding, string("ulatex+",eenconding),"")
end
function format(self::LaTeXBackend, str::String)

    #return codecs.encode(str_, self.latex_encoding)
	return str
end
function format(self::LaTeXBackend, t::Tag, text)
    local tag = tags[LaTeXBackend][t.name]
    if tag ==nothing
		if length(text)>0
			return "{$text}"
		else
			return ""
		end
    else
		if length(text)>0
            return string('\\', "$(tag){$text}")
		else
			return ""
		end
	end
end
function format(self::LaTeXBackend, href::HRef, text)
	if length(text)==0
		return ""
	elseif text == format(self,href.url)
		return "\\url{$(href.url)}"
	else
		return "\\href{$(href.url)}{$text}"
	end
end

"""
```
function format(self::LaTeXBackend, p::Protected, text)
```
```jldoctest
julia> import BibTeXFormat.RichTextElements: Protected

julia> import BibTeXFormat: render_as

julia> print(render_as(Protected("CTAN"), "latex"))
{CTAN}
```
"""
function format(self::LaTeXBackend, p::Protected, text)
	return "{$text}"
end

function write_prologue(self::LaTeXBackend, output, formatted_bibliography)
	if length(self.preamble)>0
		write(output,string(self.preamble,"\n"))
	end
	local l_label = get_longest_label(formatted_bibliography)
	write(output,"\\begin{thebibliography}{$l_label}")
end

function write_epilogue(self::LaTeXBackend, output, formatted_bibliography)
	write(output,"\n\n\\end{thebibliography}\n")
end

function write_entry(self::LaTeXBackend, output, key, label, text)
	write(output,"\n\n\\bibitem[$label]{$key}\n")
	write(output,text)
end
