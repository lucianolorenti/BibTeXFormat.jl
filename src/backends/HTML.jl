"""
HTML output backend.
```
using Backends.HTML
html = Backend()
render(Tag("em", ""),html)
```
<BLANKLINE>
render(Tag("em", "Hard &", " heavy"),html)
<em>Hard &amp; heavy</em>
render(HRef("/", ""),html)
<BLANKLINE>
render(HRef("/", "Hard & heavy"),html)
<a href="/">Hard &amp; heavy</a>
"""
module HTML

export Backend
using Base.Test

import ..Backends: BaseBackend, write_entry
import ..Backends.format

import BibTeXStyle.RichTextElements: RichText, Tag, Protected, HRef
import Formatting.sprintf1
using HttpCommon
const PROLOGUE = """<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN">
<html>
<head><meta name="generator" content="Pybtex">
<meta http-equiv="Content-Type" content="text/html; charset=%s">
<title>Bibliography</title>
</head>
<body>
<dl>
"""

"""
>>> from pybtex.richtext import Text, Tag, Symbol
>>> print(Tag('em', Text(u'Ð›.:', Symbol('nbsp'), u'<<Ð¥Ð¸Ð¼Ð¸Ñ>>')).render(Backend()))
<em>Ð›.:&nbsp;&lt;&lt;Ð¥Ð¸Ð¼Ð¸Ñ&gt;&gt;</em>

"""
struct Backend <: BaseBackend
end

const default_suffix = ".html"
const symbols = Dict{String,String}("ndash"=>"&ndash;",
									"newblock"=>"\n")

function  format(self::Backend, text::String)
    return escapeHTML(text)
end

function format(self::Backend, t::Protected,text)
	return "<span class=\"bibtex-protected\">$text</span>"
end
function format(self::Backend, t::Tag, text)
	if length(text)>0
		return "<$(t.name)>$text</$(t.name)>"
	else
		return ""
	end
end

function format(self::Backend, url::HRef, text)
    local uurl = url.url
    if length(text)>0
        return "<a href=\"$(uurl)\">$(text)</a>"
    else
        return ""
    end
end
function write_prologue(self::Backend, output)
    local encoding = nothing
    if (self.encoding == "")
        encoding = "UTF-8"
    else
        enconding  =self.encoding
    end
	write(output,sprintf1(PROLOGUE, encoding))
end
function write_epilogue(self::Backend, output)
    write(output,"</dl></body></html>\n")
end
function write_entry(self::Backend, output, key, label, text)
    write(output,"<dt>$label</dt>\n")
	write(output,"<dd>$text</dd>\n")
end

end
