module Backends
export BaseBackend,
       render_sequence,
       format,
       HTML,
       LaTeX,
       render_as

using ..RichTextElements
"""This is the base class for the backends. We encourage
you to implement as many of the symbols and tags as
possible when you create a new plugin.

symbols[u'ndash']    : Used to separate pages
symbols[u'newblock'] : Used to separate entries in the bibliography
symbols[u'nbsp']     : A non-breakable space

tags[u'em']          : emphasize text
tags[u'strong']      : emphasize text even more
tags[u'i']           : italicize text, not semantic
tags[u'b']           : embolden text, not semantic
tags[u'tt']          : typewrite text, not semantic
"""
abstract type BaseBackend end
function write_prologue(self::BaseBackend)
end
function write_epilogue(self::BaseBackend)
end
:"""Format the given string *str_*.
The default implementation simply returns the string ad verbatim.
Override this method for non-string backends.
"""
function format(self::T, str::String) where T<:BaseBackend
    return str
end

function format(self::T, r::RichText, t) where T<:BaseBackend
    return t
end

"""Format a "protected" piece of text.

In LaTeX backend, it is formatted as a {braced group}.
Most other backends would just output the text as-is.
"""
function format(self::T, t::Protected, text) where T<:BaseBackend
	return t.text
end

"""Render a sequence of rendered Text objects.
The default implementation simply concatenates
the strings in rendered_list.
Override this method for non-string backends.
"""
function render_sequence(self::T, rendered_list) where T <:BaseBackend
	return join(rendered_list, "")
end

#=
def write_to_file(self, formatted_entries, filename):
	with pybtex.io.open_unicode(filename, "w", self.encoding) as stream:
		self.write_to_stream(formatted_entries, stream)
		if hasattr(stream, 'getvalue'):
			return stream.getvalue()
=#
function write_to_stream(self::BaseBackend, formatted_bibliography, stream)

	write_prologue(self, stream)
	for entry in formatted_bibliography
		write_entry(self,stream, entry.key, entry.label, render(entry.text,self))
	end
	write_epilogue(self,stream)
end
include("HTML.jl")
include("LaTeX.jl")
    #include("Markdown.jl")

function find_backend(t::String)
    t  = lowercase(t)
    if t=="html"
        return HTML.Backend
    elseif t=="latex"
        return LaTeX.Backend
    end
end

r"""
Render this :py:class:`Text` into markup.
This is a wrapper method that loads a formatting backend plugin
and calls :py:meth:`Text.render`.

>>> text = Text("Longcat is ", Tag("em", "looooooong"), "!")
>>> print(text.render_as("html"))
Longcat is <em>looooooong</em>!
>>> print(text.render_as("latex"))
Longcat is \emph{looooooong}!
>>> print(text.render_as("text"))
Longcat is looooooong!

:param backend_name: The name of the output backend (like ``"latex"`` or
	``"html"``).

"""

function render_as(self::T, backend_name) where T<:BaseText
	backend_cls = find_backend(backend_name)
	return render(self,backend_cls())
end

function render(self::T, backend) where T<:MultiPartText

    local rendered_list = [render(part,backend) for part in self.parts]
    local text =  Backends.render_sequence(backend,rendered_list)
	return format(backend,self, text)
end

function render(self::RichString, backend)
    return format(backend,self.value)
end

function  render(self::Protected, backend)
    text = render(supertype(self),backend)
    return format_protected(backend,text)
end

function render(self::TextSymbol, backend)
    return typeof(backend).name.module.symbols[self.name]
end
end
