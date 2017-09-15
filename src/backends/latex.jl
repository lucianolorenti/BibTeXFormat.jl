#="""
LaTeX output backend.
```
using LaTeXBackends.LaTeX
latex = LaTeX.LaTeXBackend()
render(Tag("em", ""),latex)
<BLANKLINE>
render(Tag("em", "Non-", "empty"),latex)
\\emph{Non-empty}
render(HRef("/", ""),latex)
<BLANKLINE>
render(HRef("/", "Non-", "empty"),latex)
\\href{/}{Non-empty}
render(HRef("http://example.org/", "http://example.org/"),latex)
\\url{http://example.org/}
```
"""=#
using Base.Test

struct LaTeXBackend <: BaseBackend
	enconding::String
	latex_enconding::String
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
	return LaTeXBackend(eenconding, string("ulatex+",eenconding))
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
>>> from pybtex.richtext import Protected
>>> print(Protected("CTAN").render_as("latex"))
{CTAN}
"""
function format(self::LaTeXBackend, p::Protected, text)
	return "{$text}"
end

function write_prologue(self::LaTeXBackend, formatted_bibliography)
	if length(formatted_bibliography.preamble)>0
		write(output,string(formatted_bibliography.preamble,"\n"))
	end
	local longest_label = longest_label(formatted_bibliography)
	write(output,"\\begin{thebibliography}{$longest_label}")
end

function write_epilogue(self::LaTeXBackend, output)
	write(output,"\n\n\\end{thebibliography}\n")
end

function write_entry(self::LaTeXBackend, output, key, label, text)
	write(output,"\n\n\\bibitem[$label]{$key}\n")
	write(output,text)
end
