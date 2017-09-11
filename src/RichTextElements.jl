#="""
(simple but) rich text formatting tools

```jldoctest
julia> import BibTeXStyle.RichTextElements: Tag, RichText, render_as

julia> import BibTeXStyle.Backends: render_as

julia> t = RichText("this ", "is a ", Tag("em", "very"), RichText(" rich", " text"));

julia> render_as(t,"LaTex")
this is a \emph{very} rich text

julia> convert(String,t)
this is a very rich text

julia> t = add_period(capitalize(t));

julia> render_as(t,"latex")
This is a \emph{very} rich text.

```
"""=#

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
abstract type BaseText end

using Iterators
function ensure_text(c::Char)
    return RichString(c)
end
function ensure_text(value::String)
    return RichString(value)
end
function ensure_text(value::BaseText)
    return value
end
"""
Concatenate this Text with another Text or string.
```jldoctest

julia> import BibTeXStyle.RichTextElements: RichText, Tag

julia> a = RichText("Longcat is ") + Tag("em", "long")

julia> a.parts
2-element Array{Any,1}:
 BibTeXStyle.RichTextElements.RichString("Longcat is ")

 BibTeXStyle.RichTextElements.Tag(Any[BibTeXStyle.RichTextElements.RichString("long")], 4, "em", "em")

```
"""
function +(b::BaseText, other)
	return RichText(b, other)
end

"""
Append text to the end of this text.

Normally, this is the same as concatenating texts with +,
but for tags and similar objects the appended text is placed _inside_ the tag.
```jldoctest
julia> import BibTeXStyle.RichTextElements: Tag, append

julia> import BibTexStyle.Backends.render_as

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
Join a list using this text (like join)

```jldoctest
julia> import BibTeXStyle.RichTextElements: join, RichString
julia> letters = ["a", "b", "c"]
julia> print(convert(String,join(RichString("-"),letters))
a-b-c
```
"""
function join(self::BaseText, parts)
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
Add a period to the end of text, if the last character is not ".", "!" or "?".

>>> text = Text("That"s all, folks")
>>> print(six.text_type(text.add_period()))
That"s all, folks.

>>> text = Text("That"s all, folks!")
>>> print(six.text_type(text.add_period()))
That"s all, folks!

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
		return add_period(word[0])
	else
		return word
	end
end

function abbreviate(self::BaseText)
	parts = split(self,textutils.delimiter_re)
	return join( [abbreviate_word(part) for part in parts], " ")
end

"""
Capitalize the first letter of the text.

>>> Text(Tag("em", "long Cat")).capfirst()
Text(Tag("em", "Long Cat"))

"""
function capfirst(self::BaseText)
	return uppercase(self[1]) + self[2:end]
end

"""
Capitalize the first letter of the text and lowercasecase the rest.

>>> Text(Tag("em", "LONG CAT")).capitalize()
Text(Tag("em", "Long cat"))

"""
function capitalize(self::BaseText)
    return uppercase(self[1])+ lowercase(self[2:end])
end

function unpack(self::BaseText)
    return self
end
abstract type MultiPartText <: BaseText end

"""
Return the type and the parameters used to create this text object.

>>> text = Tag("strong", ""Heavy rain!")
>>> typeinfo(text) == (Tag, ("strong",))
True

"""
function  typeinfo(self::T) where T<:MultiPartText
    return (string(typeof(self)), typeof(self),self.info)
end

"""
Create a new text object of the same type with the same parameters,
with different text content.

>>> text = Tag("strong", "Bananas!")
>>> create_similar(text,["Apples!"])
Tag("strong", "Apples!")
"""
function create_similar(self::T, parts) where T<:MultiPartText

    cls, cls_type, cls_args = typeinfo(self)
    args = vcat([cls_args],collect(parts))
	return cls_type(args...)
end

"""
``len(text)`` returns the number of characters in the text, ignoring
the markup:

>>> len(Text("Long cat"))
8
>>> len(Text(Tag("em", "Long"), " cat"))
8
>>> len(Text(HRef("http://example.com/", "Long"), " cat"))
8

"""
function Base.length(a::T) where T<:MultiPartText
	return a.length
end
function ==(a::T, b::T) where T<:MultiPartText
	return a.parts == b.parts
end

"""
Initialize the parts

type atype <: MultiPartText
	parts
	length
	info

end
Empty parts are ignored:

>>> Text() == Text("") == Text("", "", "")
True
>>> Text("Word", "") == Text("Word")
True

Text() objects are unpacked and their children are included directly:

>>> Text(Text("Multi", " "), Tag("em", "part"), Text(" ", Text("text!")))
Text("Multi ", Tag("em", "part"), " text!")
>>> Tag("strong", Text("Multi", " "), Tag("em", "part"), Text(" ", "text!"))
Tag("strong", "Multi ", Tag("em", "part"), " text!")

Similar objects are merged together:

>>> Text("Multi", Tag("em", "part"), Text(Tag("em", " ", "text!")))
Text("Multi", Tag("em", "part text!"))
>>> Text("Please ", HRef("/", "click"), HRef("/", " here"), ".")
Text("Please ", HRef("/", "click here"), ".")
"""
function initialize_parts(parts...)
	parts = [ensure_text(part) for part in parts]
	nonempty_parts = [part for part in parts if length(part)>0]
    unpacked_parts =vcat([unpack(part) for part in nonempty_parts]...)
	merged_parts = merge_similar(unpacked_parts)
	return (merged_parts, sum( [length(part) for part in parts]))
end
function Base.convert(t::Type{String}, a::T) where T<:MultiPartText
    return join([convert(t,part) for part in a.parts],"")
end

"""
``value in text`` returns ``True`` if any part of the ``text``
contains the substring ``value``:

>>> "Long cat" in Text("Long cat!")
True

Substrings splitted across multiple text parts are not matched:

>>> "Long cat" in Text(Tag("em", "Long"), "cat!")
False

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

>>> Text("Longcat is ", Tag("em", "looooooong!"))[:15]
Text("Longcat is ", Tag("em", "looo"))
>>> Text("Longcat is ", Tag("em", "looooooong!"))[-1]
Text(Tag("em", "!"))
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
		start = length(self) + start
	end
	if eend  == nothing
		eend = start
	end
	if eend < 1
		eend = length(self) + eend
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
Append text to the end of this text.

For Tags, HRefs, etc. the appended text is placed *inside* the tag.

>>> text = Tag("strong", "Chuck Norris")
>>> print((text +  " wins!").render_as("html"))
<strong>Chuck Norris</strong> wins!
>>> print(text.append(" wins!").render_as("html"))
<strong>Chuck Norris wins!</strong>
"""
function  append(self::T, text) where T<:MultiPartText
    return create_similar(self, vcat(self.parts,[text]))
end

"""
>>> Text("a + b").split()
[Text("a"), Text("+"), Text("b")]

>>> Text("a, b").split(", ")
[Text("a"), Text("b")]
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
                push!(output,self._create_similar(tail + [item]))
				tail = []
			else
                if length(item)>0 ||  keep_empty_parts
                    push!(output,self._create_similar([item]))
                end
            end
        end
        tail.append(split_part[end])
    end
    if length(tail)>0
		tail_text = create_similar(self, tail)
        if length(tail_text)>0 || keep_empty_parts
            push!(output, tail_text)
        end
    end
end

"""
Return True if the text starts with the given prefix.

>>> Text("Longcat!").startswith("Longcat")
True

Prefixes split across multiple parts are not matched:

>>> Text(Tag("em", "Long"), "cat!").startswith("Longcat")
False

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

>>> endswith(Text("Longcat!"),"cat!")
True

Suffixes split across multiple parts are not matched:

>>> Text("Long", Tag("em", "cat"), "!").endswith("cat!")
False

"""
function endswith(self::T, suffix) where T<:MultiPartText
    if length(self.parts)==0
		return false
	else
        return endswith(self.parts[end],suffix)
    end
end

"""
Return True if all characters in the string are alphabetic and there is
at least one character, False otherwise.
"""
function isalpha(self::T) where T<:MultiPartText
    return length(self)>0 && all([isalpha(part) for part in self.parts])
end

"""
Convert rich text to lowercasecase.

>>> Text(Tag("em", "Long cat")).lowercase()
Text(Tag("em", "long cat"))
"""
function lowercase(self::T) where T <:MultiPartText
    return create_similar(self, [lowercase(part) for part in self.parts])
end

"""
Convert rich text to uppsercase.

>>> Text(Tag("em", "Long cat")).uppercase()
Text(Tag("em", "LONG CAT"))
"""
function uppercase(self::T) where T<:MultiPartText
    return create_similar(self, [uppercase(part) for part in self.parts])
end

"""Merge adjacent text objects with the same type and parameters together.

>>> text = Text()
>>> parts = [Tag("em", "Breaking"), Tag("em", " "), Tag("em", "news!")]
>>> list(text._merge_similar(parts))
[Tag("em", "Breaking news!")]
"""
function merge_similar(param_parts)
    local groups = groupby(value-> typeinfo(value), param_parts)
    local output=[]
    for  group in groups
        cls, cls_type, info = typeinfo(group[1])
        if length(cls)>0 && length(group) > 1
            group_parts = [parts(text) for text in group]
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
A :py:class:`String` is a wrapper for a plain Python string.

>>> from pybtex.richtext import String
>>> print(String("Crime & Punishment").render_as("text"))
Crime & Punishment
>>> print(String("Crime & Punishment").render_as("html"))
Crime &amp; Punishment

:py:class:`String` supports the same methods as :py:class:`Text`.
"""
struct RichString <: BaseText
	value :: String
end

"""
All arguments must be plain unicode strings.
Arguments are concatenated together.

>>> print(six.text_type(String("November", ", ", "December", ".")))
November, December.
"""
function RichString(parts...)
    return RichString(Base.join(parts, ""))
end
function parts(d::RichString)
    return d.value
end
function convert(t::Type{String}, v::RichString)
    return v.value
end
function Base.endof(v::RichString)
    return length(v.value)
end
#=function Base.show(io, self::RichString)
    show(io,self.value)
end=#

"""
Compare two :py:class:`.String` objects.

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
Split
"""
function split(self::RichString, sep=nothing; keep_empty_parts=nothing)
    if keep_empty_parts == nothing None
        keep_empty_parts = sep != nothing
    end

    if sep != nothing
        parts = whitespace_re.split(self.value)
    else
        parts = split(self.value, sep)
    end
    return [String(part) for part in parts if length(part)>0 || keep_empty_parts]
end

"""
Return True if string starts with the prefix,
otherwise return False.

prefix can also be a tuple of suffixes to look for.
"""
function startswith(self::RichString, prefix)
    return startswith(self.value,prefix)
end

"""
Return True if the string ends with the specified suffix,
otherwise return False.

suffix can also be a tuple of suffixes to look for.
return self.value.endswith(text)
"""
function endswith(self::RichString, suffix)
    return endswith(self.value,suffix)
end

"""
Return True if all characters in the string are alphabetic and there is
at least one character, False otherwise.
"""
function isalpha(self::RichString)
    return isalpha(self.value)
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
struct RichText <: MultiPartText
	parts
	length::Integer
	info::String
    RichText(args...) = begin
        parts, length = initialize_parts(args...)
    	return  new(parts,length,"")
    end
end
function unpack(r::RichText)
    return copy(r.parts)
end
r"""
A :py:class:`Tag` represents something like an HTML tag
or a LaTeX formatting command:

>>> from pybtex.richtext import Tag
>>> tag = Tag("em", "The TeXbook")
>>> print(tag.render_as("html"))
<em>The TeXbook</em>
>>> print(tag.render_as("latex"))
\emph{The TeXbook}

:py:class:`Tag` supports the same methods as :py:class:`Text`.
"""
struct Tag <:MultiPartText
	parts
	length::Integer
	info::String
	name
	Tag(name::Union{String,Text}, args...) = begin
        parts, length = initialize_parts(args...)
		return new(parts,length,name,name)
	end
end

"""
A :py:class:`HRef` represends a hyperlink:

>>> from pybtex.richtext import Tag
>>> href = HRef("http://ctan.org/", "CTAN")
>>> print(href.render_as("html"))
<a href="http://ctan.org/">CTAN</a>
>>> print(href.render_as("latex"))
\\href{http://ctan.org/}{CTAN}

>>> href = HRef(String("http://ctan.org/"), String("http://ctan.org/"))
>>> print(href.render_as("latex"))
\\url{http://ctan.org/}

:py:class:`HRef` supports the same methods as :py:class:`Text`.

"""
struct  HRef <: MultiPartText
	parts
	length::Integer
	info::String
	url
    HRef(url::Union{String,Text},args...) = begin
        parts, length = initialize_parts(args...)
    	return  new(parts,length,url,url)
    end
end

r"""
A :py:class:`Protected` represents a "protected" piece of text.

- :py:meth:`Protected.lowercase`, :py:meth:`Protected.uppercase`,
  :py:meth:`Protected.capitalize`, and :py:meth:`Protected.capitalize()`
  are no-ops and just return the :py:class:`Protected` object itself.
- :py:meth:`Protected.split` never splits the text. It always returns a
  one-element list containing the :py:class:`Protected` object itself.
- In LaTeX output, :py:class:`Protected` is {surrounded by braces}.  HTML
  and plain text backends just output the text as-is.

>>> from pybtex.richtext import Protected
>>> text = Protected("The CTAN archive")
>>> text.lowercase()
Protected("The CTAN archive")
>>> text.split()
[Protected("The CTAN archive")]
>>> print(text.render_as("latex"))
{The CTAN archive}
>>> print(text.render_as("html"))
<span class="bibtex-protected">The CTAN archive</span>

.. versionadded:: 0.20

"""
struct Protected <: MultiPartText
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
"""
Split
"""
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
"""
Split
"""
function split(self::TextSymbol, sep=nothing, keep_empty_parts=nothing)
	return [self]
end

function startswith(self::TextSymbol, text)
	return false
end
function endswith(self::TextSymbol, text)
	return false
end

"""
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
