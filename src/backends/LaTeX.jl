"""
LaTeX output backend.
```
using Backends.LaTeX
latex = LaTeX.Backend()
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
"""
module LaTeX
using Base.Test
import ..Backends.BaseBackend
import ..Backends.format
using ..RichTextUtils
import Formatting.sprintf1

const default_suffix = ".bbl"
const symbols = Dict{String,String}(
        "ndash"=> "--",
        "newblock"=> "\n\\newblock ",
        "nbsp"=> "~"
    )
const tags = Dict{String,Any}(
        "em"=> "emph",
        "strong"=>nothing,
        "i"=> "textit",
        "b"=> "textbf",
        "tt"=> "texttt"
    )

struct Backend <: BaseBackend
	enconding::String
	latex_enconding::String
end
function Backend(enconding=nothing)
	local eenconding = "UTF-8"
	return Backend(eenconding, string("ulatex+",eenconding))
end
function format(self::Backend, str::String)

    #return codecs.encode(str_, self.latex_encoding)
	return str
end
function format(self::Backend, t::Tag, text)
    local tag = tags[t.name]
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
function format(self::Backend, href::HRef, text)
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
function format(self::Backend, p::Protected, text)
	return "{$text}"
end

function write_prologue(self::Backend, formatted_bibliography)
	if length(formatted_bibliography.preamble)>0
		write(output,string(formatted_bibliography.preamble,"\n"))
	end
	local longest_label = longest_label(formatted_bibliography)
	write(output,"\\begin{thebibliography}{$longest_label}")
end

function write_epilogue(self::Backend, output)
	write(output,"\n\n\\end{thebibliography}\n")
end

function write_entry(self::Backend, output, key, label, text)
	write(output,"\n\n\\bibitem[$label]{$key}\n")
	write(output,text)
end
end
