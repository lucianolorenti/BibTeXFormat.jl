module RichTextElements
export Tag, TextSymbol, RichText, unpack, capitalize,  ensure_text
import Base.==
import Base.getindex
import Base.split
import Base.join
import Base.convert
import Base.uppercase
import Base.endof
import Base.lowercase
import Base.endswith
import Base.+
import Base.isalpha
import Base.append!
import Base.show
import Base.startswith
import Base.write
import Base.isempty
import BibTeXFormat: delimiter_re
abstract type BaseText end
import BibTeXFormat: whitespace_re, render_as
function typeinfo(v::T) where T<:BaseText
    return (string(T),T,())
end
#using Iterators
function ensure_text(c::Char)
    return RichString(string(c))
end
function ensure_text(value::String)
    return RichString(value)
end
function ensure_text(value::T) where T<:BaseText
    return value
end
function isempty(value::T) where T<:BaseText
    return length(value) == 0
end
"""
```julia
function +(b::BaseText, other)
```
Concatenate this Text with another Text or string.
```jldoctest
julia> a = RichText("Longcat is ") + Tag("em", "long")
RichText("Longcat is ", Tag("em", "long"))

```
"""
function +(b::BaseText, other)
	return RichText(b, other)
end

"""
```julia
function append(self::BaseText, text)
```
Append text to the end of this text.

Normally, this is the same as concatenating texts with +,
but for tags and similar objects the appended text is placed _inside_ the tag.
```jldoctest
julia> text = Tag("em", "Look here");

julia> print(render_as(text + "!","html"))
<em>Look here</em>!

julia> print(render_as(append(text,"!"),"html"))
<em>Look here!</em>

```
"""
function append(self::BaseText, text)
	return self+text
end

"""
```julia
function join(self::T, parts) where T<:BaseText
```
Join a list using this text (like join)

```jldoctest
julia> letters = ["a", "b", "c"];

julia> print(convert(String,join(RichString("-"),letters)))
a-b-c

```
"""
function join(self::T, parts) where T<:BaseText
    if length(parts) == 0
	    return Text()
    end
    joined = []
	for part in parts
		if length(joined) > 0
			push!(joined,self)
        end
	 	push!(joined,part)
    end
	return RichText(joined...)
end

"""
```julia
function add_period(self::BaseText, period=".")
```
Add a period to the end of text, if the last character is not ".", "!" or "?".

```jldoctest
julia> text = RichText("That's all, folks");

julia> print(convert(String,add_period(text)))
That's all, folks.

julia> text = RichText("That's all, folks!");

julia> print(convert(String,add_period(text)))
That's all, folks!
```
"""
function add_period(self::BaseText, period=".")
    if length(self)>0 &&   (!endswith(self,['.','?','!']))
		return append(self,period)
	else
		return self
	end
end
function  abbreviate_word(word)
	if isalpha(word)
		return add_period(word[1])
	else
		return word
	end
end
function abbreviate(self::BaseText)
	parts = split(self, delimiter_re)
    return join(RichText(" "),[abbreviate_word(part) for part in parts])
end

"""
```julia
function capfirst(self::BaseText)
```
Capitalize the first letter of the text.
```jldoctest
julia> capfirst(RichText(Tag("em", "long Cat")))
RichText(Tag("em", "Long Cat"))

```

"""
function capfirst(self::BaseText)
	return uppercase(self[1]) + self[2:end]
end

"""
```julia
function capitalize(self::BaseText)
```
Capitalize the first letter of the text and lowercasecase the rest.

```jldoctest
julia> capitalize(RichText(Tag("em", "LONG CAT")))
RichText(Tag("em", "Long cat"))

```

"""
function capitalize(self::BaseText)
    return uppercase(self[1])+ lowercase(self[2:end])
end

function unpack(self::T) where T <:BaseText
    return [self]
end
abstract type MultiPartText <: BaseText end

"""
```julia
function  typeinfo(self::T) where T<:MultiPartText
```
Return the type and the parameters used to create this text object.

```jldoctest
julia> using BibTeXFormat

julia> import BibTeXFormat.RichTextElements: Tag, typeinfo

julia> text = Tag("strong", "Heavy rain!");

julia> typeinfo(text) == ("BibTeXFormat.RichTextElements.Tag", BibTeXFormat.RichTextElements.Tag, "strong")
true
```

"""
function  typeinfo(self::T) where T<:MultiPartText
    return (string(typeof(self)), typeof(self),self.info)
end

function parts(d::T) where T<:MultiPartText
    return d.parts
end
function show(io::Union{IO,Base.GenericIOBuffer}, d::T) where {T<:MultiPartText}
    write(io,string(T.name.name))
    write(io,"(")
    write(io,Base.join([string(part) for part in d.parts], ", "))
    write(io,")")
end
"""
```julia
function create_similar(self::T, parts) where T<:MultiPartText
```
Create a new text object of the same type with the same parameters,
with different text content.
```jldoctest
julia> text = Tag("strong", "Bananas!");

julia> create_similar(text,["Apples!"])
Tag("strong", "Apples!")

```
"""
function create_similar(self::T, parts) where T<:MultiPartText
    cls, cls_type, cls_args = typeinfo(self)
    args = vcat([cls_args],collect(parts))
	return cls_type(args...)
end

"""
``lenght(text)`` returns the number of characters in the text, ignoring
the markup:
```jldoctest
julia> length(RichText("Long cat"))
8
julia> length(RichText(Tag("em", "Long"), " cat"))
8
julia> length(RichText(HRef("http://example.com/", "Long"), " cat"))
8

```
"""
function Base.length(a::T) where T<:MultiPartText
    return a.length
end
function ==(a::T, b::T) where T<:MultiPartText
	return a.parts == b.parts
end

"""
Initialize the parts.
A MutliPartText elements must have the following members
```julia
type atype <: MultiPartText
	parts
	length
	info
end
```

Empty parts are ignored:
```jldoctest
julia> RichText() == RichText("") == RichText("", "", "")
true
julia> RichText("Word", "") == RichText("Word")
true
```
Text() objects are unpacked and their children are included directly:
```jldoctest
julia> RichText(RichText("Multi", " "), Tag("em", "part"), RichText(" ", RichText("text!")))
RichText("Multi ", Tag("em", "part"), " text!")

julia> Tag("strong", RichText("Multi", " "), Tag("em", "part"), RichText(" ", "text!"))
Tag("strong", "Multi ", Tag("em", "part"), " text!")

```
Similar objects are merged together:
```jldoctest
julia> RichText("Multi", Tag("em", "part"), RichText(Tag("em", " ", "text!")))
RichText("Multi", Tag("em", "part text!"))

julia> RichText("Please ", HRef("/", "click"), HRef("/", " here"), ".")
RichText("Please ", HRef("/", "click here"), ".")
```
"""
function initialize_parts(partso...)
	parts = [ensure_text(part) for part in partso]
	nonempty_parts = [part for part in parts if length(part)>0]
    unpacked_parts =vcat([unpack(part) for part in nonempty_parts]...)
	merged_parts = merge_similar(unpacked_parts)

	return (merged_parts, Base.sum(vcat(0,[length(part) for part in merged_parts])))
end
function Base.convert(t::Type{String}, a::T) where T<:MultiPartText
    return Base.join([convert(String,part) for part in a.parts],"")
end

"""
``value in text`` returns ``True`` if any part of the ``text``
contains the substring ``value``:
```jldoctest
julia> contains(RichText("Long cat!"),"Long cat")
true
```
Substrings splitted across multiple text parts are not matched:
```jldoctest
julia> contains(RichText(Tag("em", "Long"), "cat!"),"Long cat")
false

```

"""
function Base.contains(a::T, item::String) where T<:MultiPartText
	return  any( [contains(part,item) for part in a.parts])
end
function Base.endof(a::T) where T<:MultiPartText
    return a.length
end

"""
Slicing and extracting characters works like with regular strings,
formatting is preserved.
```jldoctest
julia> RichText("Longcat is ", Tag("em", "looooooong!"))[1:15]
RichText("Longcat is ", Tag("em", "looo"))

julia> RichText("Longcat is ", Tag("em", "looooooong!"))[end]
RichText(Tag("em", "!"))
```
"""
function getindex(a::T, key::Integer) where T<:MultiPartText
	local start=key
	local eend = nothing
	return getindex(a,start,eend,1)
end
function getindex(a::T, key::UnitRange) where T<:MultiPartText
	local start = first(key)
	local eend  = last(key)
	local sstep =  step(key)
	return getindex(a,start,eend,sstep)
end
function getindex(a::T, start::Integer, eend, step::Integer) where T<:MultiPartText

	if step != 1
		error("Not Implemented")
	end
	if start < 1
		start = length(a) + start
	end
	if eend  == nothing
		eend = start
	end
	if eend < 1
		eend = length(a) + eend
	end
    return slice_beginning(slice_end(a,length(a) - start+1),eend - start+1)
end

"""
Return a text consistng of the first slice_length characters
of this text (with formatting preserved).
"""
function slice_beginning(self::T, slice_length::Integer) where T<:MultiPartText
	local parts = []
	local len = 0
	for part in self.parts
		if len + length(part) > slice_length
			push!(parts,part[1:slice_length - len])
			break
		else
			push!(parts,part)
			len = len +  length(part)
		end
	end
	return create_similar(self,parts)
end

"""
```
function slice_end(self::T, slice_length::Integer) where T<:MultiPartText
```
Return a text consistng of the last slice_length characters
of this text (with formatting preserved).
"""
function slice_end(self::T, slice_length::Integer) where T<:MultiPartText
	local parts = []
	local len = 0
	for part in reverse(self.parts)
		if len + length(part) > slice_length
			push!(parts,part[length(part) - (slice_length - len)+1:end])
			break
		else
			push!(parts,part)
			len = len + length(part)
		end
	end
	return create_similar(self,reverse(parts))
end

"""
```
function  append(self::T, text) where T<:MultiPartText
```
Append text to the end of this text.

For Tags, HRefs, etc. the appended text is placed *inside* the tag.
```jldoctest
julia> using  BibTeXFormat

julia> text = Tag("strong", "Chuck Norris");

julia> print(render_as(text +  " wins!","html"))
<strong>Chuck Norris</strong> wins!
julia> print(render_as(append(text," wins!"),"html"))
<strong>Chuck Norris wins!</strong>
```
"""
function  append(self::T, text) where T<:MultiPartText
    return create_similar(self, vcat(self.parts,[text]))
end

function append!(self::T, text) where T<:MultiPartText
    local new_parts = vcat(self.parts, text)
    parts, l = initialize_parts(new_parts...)
    self.parts = parts
    self.length =l
end

"""
```
function split(self::T, sep=nothing; keep_empty_parts=nothing) where T <:MultiPartText
```
```jldoctest
julia> print(split(RichText("a + b")))
Any[RichText("a"), RichText("+"), RichText("b")]
julia> print(split(RichText("a, b"), ", "))
Any[RichText("a"), RichText("b")]
```
"""
function split(self::T, sep=nothing; keep_empty_parts=nothing) where T <:MultiPartText
	if keep_empty_parts == nothing
        keep_empty_parts = (sep != nothing)
    end
    local tail = nothing
    if keep_empty_parts
        tail = [""]
    else
        tail = []
    end
    output = []
	for part in self.parts
		split_part = split(part,sep, keep_empty_parts=true)
        if length(split_part)==0
			continue
        end
        for item in split_part[1:end-1]
            if length(tail)>0
                push!(output,create_similar(self, vcat(tail,[item])))
				tail = []
			else
                if length(item)>0 ||  keep_empty_parts
                    push!(output,create_similar(self,[item]))
                end
            end
        end
        push!(tail,split_part[end])
    end
    if length(tail)>0
		tail_text = create_similar(self, tail)
        if length(tail_text)>0 || keep_empty_parts
            push!(output, tail_text)
        end
    end
end

"""
```
function startswith(self::T, prefix) where T<:MultiPartText
```
Return True if the text starts with the given prefix.
```jldoctest
julia> startswith(RichText("Longcat!"),"Longcat")
true
```

Prefixes split across multiple parts are not matched:
```jldoctest
julia> startswith(RichText(Tag("em", "Long"), "cat!"),"Longcat")
false
```
"""
function startswith(self::T, prefix) where T<:MultiPartText
    if length( self.parts) == 0
		return false
	else
        return startswith(self.parts[1],prefix)
    end
end

"""
Return True if the text ends with the given suffix.
```jldoctest
julia> endswith(RichText("Longcat!"),"cat!")
true

```
Suffixes split across multiple parts are not matched:
```jldoctest
julia> endswith(RichText("Long", Tag("em", "cat"), "!"),"cat!")
false

```

"""
function endswith(self::T, suffix) where T<:MultiPartText
    if length(self.parts)==0
		return false
	else
        return endswith(self.parts[end],suffix)
    end
end

"""
```
function isalpha(self::T) where T<:MultiPartText
```
Return true if all characters in the string are alphabetic and there is
at least one character, False otherwise.
"""
function isalpha(self::T) where T<:MultiPartText
    return length(self)>0 && all([isalpha(part) for part in self.parts])
end

"""
```
function lowercase(self::T) where T <:MultiPartText
```
Convert rich text to lowercasecase.
```jldoctest
julia> lowercase(RichText(Tag("em", "Long cat")))
RichText(Tag("em", "long cat"))
```
"""
function lowercase(self::T) where T <:MultiPartText
    return create_similar(self, [lowercase(part) for part in self.parts])
end

"""
Convert rich text to uppsercase.
```jldoctest
julia> uppercase(RichText(Tag("em", "Long cat")))
RichText(Tag("em", "LONG CAT"))
```
"""
function uppercase(self::T) where T<:MultiPartText
    return create_similar(self, [uppercase(part) for part in self.parts])
end

"""
```julia
function merge_similar(param_parts)
```
Merge adjacent text objects with the same type and parameters together.
```jldoctest
julia> parts = [Tag("em", "Breaking"), Tag("em", " "), Tag("em", "news!")];

julia> print(merge_similar(parts))
Any[Tag("em", "Breaking news!")]

```
"""
function merge_similar(param_parts)
    local groups = nothing
        groups = groupby(value-> RichTextElements.typeinfo(value)[1], param_parts)
    local output=[]
    for  group in groups
        cls, cls_type, info = typeinfo(group[1])
        if length(cls)>0 && length(group) > 1
            group_parts = vcat([parts(text) for text in group]...)
            args = vcat(info, group_parts)
            push!(output, cls_type(args...))
		else
			for text in group
                push!(output,text)
            end
        end
    end
    return output
end

"""
A `RichString` is a wrapper for a plain Julia string.

```jldoctest
julia> print(render_as(RichString("Crime & Punishment"),"text"))
Crime & Punishment
julia> print(render_as(RichString("Crime & Punishment"),"html"))
Crime &amp; Punishment

```
"""
struct RichString <: BaseText
	value :: String
end

"""
All arguments must be plain unicode strings.
Arguments are concatenated together.
```jldoctest
julia> print(convert(String,RichString("November", ", ", "December", ".")))
November, December.
```
"""
function RichString(parts...)
    return RichString(Base.join(parts, ""))
end
function parts(d::RichString)
    return [convert(String,d)]
end
function convert(t::Type{String}, v::RichString)
    return v.value
end
function Base.endof(v::RichString)
    return length(v.value)
end
function Base.show(io::Union{IO,Base.GenericIOBuffer}, self::RichString)
    write(io, "\"")
    write(io, self.value)
    write(io,"\"")
end

"""
Compare two `RichString` objects.

"""
function ==(a::RichString, b::RichString)
    return a.value == b.value
end
function Base.length(self::RichString)
    return  length(self.value)
end
function Base.contains(self::RichString, item)
    return contains(self.value,item)
end
function getindex(self::RichString, index)
    return RichString(string(self.value[index]))
end
"""
```
function split(self::RichString, sep=nothing; keep_empty_parts=nothing)
```
Split
"""
function split(self::RichString, sep=nothing; keep_empty_parts=nothing)
    if keep_empty_parts == nothing None
        keep_empty_parts = sep != nothing
    end

    if sep == nothing
        parts = split(self.value, whitespace_re)
    else
        parts = split(self.value, sep)
    end
    return [String(part) for part in parts if length(part)>0 || keep_empty_parts]
end

"""
```
function startswith(self::RichString, prefix)
```
Return True if string starts with the prefix,
otherwise return False.

prefix can also be a tuple of suffixes to look for.
"""
function startswith(self::RichString, prefix)
    return startswith(self.value,prefix)
end

"""
```
function endswith(self::RichString, suffix)
```
Return True if the string ends with the specified suffix,
otherwise return False.

suffix can also be a tuple of suffixes to look for.
`return value.endswith(self.value text)`
"""
function endswith(self::RichString, suffix)
    return endswith(self.value,suffix)
end

"""
Return True if all characters in the string are alphabetic and there is
at least one character, False otherwise.
"""
function isalpha(self::RichString)
    return all(isalpha, self.value)
end
function lowercase(self::RichString)
    return String(lowercase(self.value))
end
function uppercase(self::RichString)
    return String(uppercase(self.value))
end
function typeinfo(self::RichString)
    return (string(RichString),RichString, [])
end
mutable struct RichText <: MultiPartText
	parts
	length::Integer
	info::String
    RichText(args...) = begin
        parts, l = initialize_parts(args...)
        return  new(parts,l,"")
    end
end
function unpack(r::RichText)
	local elems = []
	for t in r.parts
		elems = vcat(elems, unpack(t))
	end
	return elems
end
function write(io::Base.GenericIOBuffer, d::RichText)
    show(io,d)
end

function show(io::Union{IO,Base.GenericIOBuffer}, d::RichText)
    write(io,"RichText")
    write(io,"(")
    write(io,Base.join([string(part) for part in d.parts], ", "))
    write(io,")")
end
"""
A `Tag` represents something like an HTML tag or a LaTeX formatting command:

```jldoctest
julia> import BibTeXFormat: render_as

julia> tag = Tag("em", "The TeXbook");

julia> render_as(tag, "latex")
"\\emph{The TeXbook}"

julia> render_as(tag, "html")
"<em>The TeXbook</em>"

```
"""
mutable struct Tag <:MultiPartText
	parts
	length::Integer
	info::String
	name
	Tag(name::Union{String,Text}, args...) = begin
        parts, length = initialize_parts(args...)
		return new(parts,length,name,name)
	end
end

function Base.show(io::Union{IO, Base.GenericIOBuffer}, self::Tag)
    write(io,"Tag")
    write(io,"(\"")
    write(io, self.name)
    write(io, "\", ")
    write(io,Base.join([string(part) for part in self.parts], ", "))
    write(io,")")
end

"""
A `HRef` represends a hyperlink:
```jldoctest
julia> import BibTeXFormat: render_as

julia> href = HRef("http://ctan.org/", "CTAN");

julia> print(render_as(href,"html"))
<a href="http://ctan.org/">CTAN</a>

julia> print(render_as(href, "latex"))
\\href{http://ctan.org/}{CTAN}

julia> href = HRef(String("http://ctan.org/"), String("http://ctan.org/"));

julia> print(render_as(href,"latex"))
\\url{http://ctan.org/}

```

"""
mutable struct HRef <: MultiPartText
	parts
	length::Integer
	info::String
	url
    HRef(url,args...) = begin
        parts, length = initialize_parts(args...)
    	return  new(parts,length,url,url)
    end
end

function Base.show(io::Union{IO, Base.GenericIOBuffer}, self::HRef)
    write(io,"HRef")
    write(io,"(\"")
    write(io, self.url)
    write(io, "\", ")
    write(io,Base.join([string(part) for part in self.parts], ", "))
    write(io,")")
end

"""
A `Protected` represents a "protected" piece of text.

- `Protected.lowercase`, `Protected.uppercase`, `Protected.capitalize`, and `Protected.capitalize()`   are no-ops and just return the `Protected` struct itself.
- `split` never splits the text. It always returns a  one-element list containing the `Protected` struct itself.
- In LaTeX output, `Protected` is {surrounded by braces}.  HTML  and plain text backends just output the text as-is.

```jldoctest
julia> import BibTeXFormat: render_as

julia> import BibTeXFormat.RichTextElements: Protected, RichString

julia> text = Protected("The CTAN archive");

julia> lowercase(text)
Protected("The CTAN archive")

julia> print(split(text))
BibTeXFormat.RichTextElements.Protected[Protected("The CTAN archive")]

julia> print(render_as(text, "latex"))
{The CTAN archive}

julia> print(render_as(text,"html"))
<span class="bibtex-protected">The CTAN archive</span>

```
"""
mutable struct Protected <: MultiPartText
	parts
	length::Integer
	info::String
	Protected(parts...) = begin
        parts, length = initialize_parts(parts...)
        new(parts,length,"")
    end
end
function capfirst(self::Protected)
	return self
end
function  capitalize(self::Protected)
	return self
end

function lowercase(self::Protected)
	return self
end

function uppercase(self::Protected)
	return self
end
function split(self::Protected, sep=nothing, keep_empty_parts=nothing)
	return [self]
end
struct TextSymbol <: BaseText
	name :: String
	info :: String
end
function TextSymbol(name::String)
	return TextSymbol(name,name)
end
function Base.length(t::TextSymbol)
	return 1
end
function ==(a::TextSymbol, b::TextSymbol)
	return a.name == b.name
end
function getindex(self::TextSymbol, a::Integer)
	local result = nothing
	try
		result = "a"[a]
	catch e
		error(e)
		return
	end
	if (length(result)>0)
		return self
	else
		return ""
	end
end
function split(self::TextSymbol, sep=nothing, keep_empty_parts=nothing)
	return [self]
end

function startswith(self::TextSymbol, text)
	return false
end
function endswith(self::TextSymbol, text)
	return false
end
function convert(::Type{String}, v::TextSymbol)
	return "<$(v.name)>"
end
"""
```
function isalpha(self::TextSymbol)
```
A TextSymbol is not alfanumeric. Returns false
"""
function isalpha(self::TextSymbol)
	return false
end
function uppercase(self::TextSymbol)
    return self
end
function lowercase(self::TextSymbol)
	return self
end
const nbsp = TextSymbol("nbsp")
end
