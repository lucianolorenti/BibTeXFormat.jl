export write_to_stream,
       write_to_file,
       write_to_string,
       render_as,
       HTMLBackend,
       LaTeXBackend,
       MarkdownBackend,
       TextBackend
"""
This is the base type for the backends. We encourage you to implement as many of the symbols and tags as possible when you create a new plugin.

* `symbols["ndash"]`    : Used to separate pages
* `symbols["newblock"]` : Used to separate entries in the bibliography
* `symbols["bst_script"]`      : A non-breakable space

* `tags[""em']`   : emphasize text
* `tags["strong"]`: emphasize text even more
* `tags["i"]`     : italicize text, not semantic
* `tags["b"]`     : embolden text, not semantic
* `tags["tt"]`    : typewrite text, not semantic
"""
abstract type BaseBackend end
import BibTeXFormat.RichTextElements: RichText, Protected, BaseText, MultiPartText, RichString, TextSymbol,Tag, HRef
const symbols = Dict{Type,Dict{String,String}}(
             BaseBackend=>Dict{String,String}(
                "ndash"=> "'&ndash;",
                "newblock"=> "\n",
                "nbsp"=> "&nbsp;"))
const tags    = Dict{Type,Dict{String,String}}()
const default_suffix = Dict{Type,String}()

function write_prologue(self::BaseBackend, s)
end
function write_epilogue(self::BaseBackend,s )
end
"""
```
function format(self::T, str::String) where T<:BaseBackend
```
Format the given string *str_*.
The default implementation simply returns the string ad verbatim.
Override this method for non-string backends.
"""
function format(self::T, str::String) where T<:BaseBackend
    return str
end

function format(self::T, r::RichText, t) where T<:BaseBackend
    return convert(String,t)
end

"""
```
function format(self::T, t::Protected, text) where T<:BaseBackend
```
Format a "protected" piece of text.

In LaTeX backend, it is formatted as a {braced group}.
Most other backends would just output the text as-is.
"""
function format(self::T, t::Protected, text) where T<:BaseBackend
    return text
end

"""
```
function render_sequence(self::T, rendered_list) where T <:BaseBackend
```
Render a sequence of rendered Text objects.
The default implementation simply concatenates
the strings in rendered_list.
Override this method for non-string backends.
"""
function render_sequence(self::T, rendered_list) where T <:BaseBackend
	return Base.join(rendered_list, "")
end

function write_entry()
end

function  write_to_file(self, formatted_entries, filename)
    file = open(filename, "w")
    write_to_stream(self, formatted_entries, file)
    close(file)
end
function write_to_string(self, formatted_entries)
    local buff = IOBuffer()
    write_to_stream(self, formatted_entries, buff)
    return String(buff)
end
function write_to_stream(self::BaseBackend, formatted_bibliography, stream=IOBuffer())

    write_prologue(self, stream)
    for (key, text, label ) in formatted_bibliography
        write_entry(self, stream, key, label,  render(text,self))
	end
	write_epilogue(self,stream)
    return stream
end
    #include("Markdown.jl")

function find_backend(t::String)
    t  = lowercase(t)
    if t=="html"
        return HTMLBackend
    elseif t=="latex"
        return LaTeXBackend
    elseif t=="text"
        return TextBackend
    elseif t=="markdown"
        return MarkdownBackend
    end
end

doc"""
```
function render_as(self::T, backend_name) where T<:BaseText
```
Render `BaseText` into markup.
This is a wrapper method that loads a formatting backend plugin and calls :py `render(:BaseText)`. `backend_name` is  the name of the output backend ( `"latex", `"html", `"markdown"`, `"text"`).
```jldoctest
julia> import BibTeXFormat.RichTextElements: RichText, Tag

julia> import BibTeXFormat: render_as

julia> text = RichText("Longcat is ", Tag("em", "looooooong"), "!");

julia> print(render_as(text, "html"))
Longcat is <em>looooooong</em>!
julia> print(render_as(text, "latex"))
Longcat is \emph{looooooong}!
julia> print(render_as(text, "text"))
Longcat is looooooong!

```

"""

function render_as(self::T, backend_name) where T<:BaseText
	backend_cls = find_backend(backend_name)
	return render(self,backend_cls())
end
function render_multipart(self::T, backend) where T<:MultiPartText
    local rendered_list = [render(part,backend) for part in self.parts]
    local text =  render_sequence(backend,rendered_list)
	return format(backend,self, text)
end
function render(self::T, backend) where T<:MultiPartText
    return render_multipart(self,backend)
end

function render(self::RichString, backend)
    return format(backend,self.value)
end

function render(self::TextSymbol, backend)
    local s = get(symbols[typeof(backend)],self.name,nothing)
    if (s==nothing)
        return get(symbols[BaseBackend],self.name, nothing)
    else
        return s
    end
end
include("html.jl")
include("latex.jl")
include("markdown.jl")
include("plaintext.jl")
