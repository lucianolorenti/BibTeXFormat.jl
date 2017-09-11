#="""
HTML output backend.
```
using HTMLBackends.HTML
html = HTMLBackend()
render(Tag("em", ""),html)
```
<BLANKLINE>
render(Tag("em", "Hard &", " heavy"),html)
<em>Hard &amp; heavy</em>
render(HRef("/", ""),html)
<BLANKLINE>
render(HRef("/", "Hard & heavy"),html)
<a href="/">Hard &amp; heavy</a>
"""=#
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
>>> print(Tag('em', Text(u'Ð›.:', Symbol('nbsp'), u'<<Ð¥Ð¸Ð¼Ð¸Ñ>>')).render(HTMLBackend()))
<em>Ð›.:&nbsp;&lt;&lt;Ð¥Ð¸Ð¼Ð¸Ñ&gt;&gt;</em>

"""
struct HTMLBackend <: BaseBackend
end

const default_suffix = ".html"
const symbols = Dict{String,String}("ndash"=>"&ndash;",
									"newblock"=>"\n")

function  format(self::HTMLBackend, text::String)
    return escapeHTML(text)
end

function format(self::HTMLBackend, t::Protected,text)
	return "<span class=\"bibtex-protected\">$text</span>"
end
function format(self::HTMLBackend, t::Tag, text)
	if length(text)>0
		return "<$(t.name)>$text</$(t.name)>"
	else
		return ""
	end
end

function format(self::HTMLBackend, url::HRef, text)
    local uurl = url.url
    if length(text)>0
        return "<a href=\"$(uurl)\">$(text)</a>"
    else
        return ""
    end
end
function write_prologue(self::HTMLBackend, output)
    local encoding = nothing
    if (self.encoding == "")
        encoding = "UTF-8"
    else
        enconding  =self.encoding
    end
	write(output,sprintf1(PROLOGUE, encoding))
end
function write_epilogue(self::HTMLBackend, output)
    write(output,"</dl></body></html>\n")
end
function write_entry(self::HTMLBackend, output, key, label, text)
    write(output,"<dt>$label</dt>\n")
	write(output,"<dd>$text</dd>\n")
end